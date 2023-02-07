// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import UIKit
import CryptoKit
import LocalAuthentication
import FirebaseAuth

// MARK: - LaunchViewController

class LaunchViewController: UIViewController {
  // MARK: - Properties

  private let localAuthenticationContext = LAContext()
  private var localAuthenticationError: NSError?
  private var userID: String?
  private var config: Config?
  private var privateKey: P256.KeyAgreement.PrivateKey?

  // MARK: - Subviews

  private lazy var logoImageView = makeLogoImageView()

  // MARK: - Constraints

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    startBlinkingAnimation()
    launchAuthProcess()
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

  private func launchAuthProcess() {
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
            self?.userID = userID
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

  // MARK: - Error Handling

  private func handleError(_ error: Error? = nil) {
    showErrorAlert(message: error?.localizedDescription)
  }
}

// MARK: - LocalConstants

private enum LocalConstants {
  static let logoImageViewSideOffset: CGFloat = 64.0
}
