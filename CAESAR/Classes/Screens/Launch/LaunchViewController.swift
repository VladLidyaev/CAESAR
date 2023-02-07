// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import UIKit
import CryptoKit
import LocalAuthentication
import FirebaseAuth

// MARK: - LaunchViewController

class LaunchViewController: UIViewController {
  // MARK: - Properties

  // MARK: - Computed variables

  // MARK: - Subviews

  private lazy var logoImageView = makeLogoImageView()

  // MARK: - Constraints

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
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

  
}

// MARK: - LocalConstants

private enum LocalConstants {
  static let logoImageViewSideOffset: CGFloat = 64.0
}
