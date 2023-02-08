// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import UIKit
import CryptoKit
import LocalAuthentication
import FirebaseAuth

// MARK: - LaunchViewController

class LaunchViewController: CaesarViewController {
  // MARK: - Properties

  private let localAuthenticationContext = LAContext()
  private var localAuthenticationError: NSError?

  // MARK: - Subviews

  private lazy var logoImageView = makeLogoImageView()

  // MARK: - Constraints

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    startBlinkingAnimation()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    auth()
  }

  // MARK: - Setup UI

  private func setupUI() {
    view.backgroundColor = Colors.background
    view.addSubview(logoImageView)
    setupConstraints()
  }

  private func setupConstraints() {
    // LogoImageView
    logoImageView.pinToSuperviewSafeAreaEdge(.top)
    logoImageView.pinToSuperviewSafeAreaEdge(.leading, offset: LocalConstants.logoImageViewSideOffset)
    logoImageView.pinToSuperviewSafeAreaEdge(.bottom)
    logoImageView.pinToSuperviewSafeAreaEdge(.trailing, offset: -LocalConstants.logoImageViewSideOffset)
  }

  // MARK: - View Constructors

  private func makeLogoImageView() -> UIImageView {
    let imageView = UIImageView(image: Icons.logoTitle).autoLayout()
    imageView.contentMode = .scaleAspectFit
    return imageView
  }

  // MARK: - Private Methods

  private func startBlinkingAnimation() {
    logoImageView.alpha = .one
    UIView.animate(
      withDuration: Constants.Animation.blinking,
      delay: .zero,
      options: [.repeat, .autoreverse, .curveEaseInOut],
      animations: { [weak self] in
        self?.logoImageView.alpha = .zero
      }
    )
  }

  // MARK: - Auth Process

  private func auth() {
    let onError: (Error?) -> () = { [weak self] error in
      self?.showErrorAlert(message: error?.localizedDescription)
    }

    guard SecureEnclave.isAvailable else {
      onError(LocalError.noAccessToSecureEnclave)
      return
    }

    guard SystemProvider.isConnectedToNetwork else {
      onError(LocalError.noNetworkConnection)
      return
    }

    localAuth(
      onSuccess: { [weak self] in
        self?.remoteAuth(
          onSuccess: { userID in
            self?.createPrivateKey(
              onSuccess: { privateKey in
                self?.launchManager(
                  userInfo: UserInfo(
                    userID: userID,
                    privateKey: privateKey
                  )
                )
              },
              onError: onError
            )
          },
          onError: onError
        )
      },
      onError: onError
    )
  }

  // MARK: - Local Auth

  private func localAuth(
    onSuccess: @escaping () -> Void,
    onError: @escaping (Error?) -> Void
  ) {
    guard
      localAuthenticationContext.canEvaluatePolicy(
        .deviceOwnerAuthenticationWithBiometrics,
        error: &localAuthenticationError
      )
    else {
      onError(LocalError.biometryIsNotAvailble)
      return
    }

    localAuthenticationContext.evaluatePolicy(
      .deviceOwnerAuthenticationWithBiometrics,
      localizedReason: Strings.LocalAuthenticationContext.reason
    ) { isSuccess, error in
      guard isSuccess else {
        DispatchQueue.main.async { onError(error) }
        return
      }
      onSuccess()
    }
  }

  // MARK: - Remote Auth

  private func remoteAuth(
    onSuccess: @escaping (String) -> Void,
    onError: @escaping (Error?) -> Void
  ) {
    Auth.auth().signInAnonymously { authResult, error in
      guard let authResult = authResult else {
        onError(error)
        return
      }
      onSuccess(authResult.user.uid)
    }
  }

  // MARK: - Private Key

  private func createPrivateKey(
    onSuccess: @escaping (SecureEnclave.P256.KeyAgreement.PrivateKey) -> Void,
    onError: @escaping (Error?) -> Void
  ) {
    do {
      let privateKey = try SecureEnclave.P256.KeyAgreement.PrivateKey()
      onSuccess(privateKey)
    } catch {
      onError(error)
      return
    }
  }

  // MARK: - Caesar Manager

  private func launchManager(userInfo: UserInfo) {
    let manager = CaesarManager(
      userInfo: userInfo,
      viewController: self
    )
    self.manager = manager
    manager.launch()
  }

  // MARK: - Error Handling

  private func handleError(_ error: Error? = nil) {
    showErrorAlert(message: error?.localizedDescription)
  }
}

// MARK: - LocalConstants

private enum LocalConstants {
  static let logoImageViewSideOffset: CGFloat = 64.0
}
