// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import UIKit

// MARK: - ShowErrorAlert

extension UIViewController {
  func showErrorAlert(message: String? = nil) {
    let alertMessage = message ?? Strings.ErrorViewController.message
    let alert = UIAlertController(
      title: Strings.ErrorViewController.title,
      message: alertMessage,
      preferredStyle: .alert
    )
    self.present(alert, animated: true, completion: nil)
  }
}

// MARK: - Present With Dimm Animation

extension UIViewController {
  func present(_ viewContrtoller: UIViewController) {
    UIView.animate(withDuration: Constants.Animation.default) { [weak self] in
      self?.view.layer.opacity = .zero
    } completion: { [weak self] _ in
      viewContrtoller.view.layer.opacity = .zero
      self?.present(
        viewContrtoller,
        animated: false,
        completion: {
          UIView.animate(withDuration: Constants.Animation.default) {
            viewContrtoller.view.layer.opacity = .one
          } completion: { _ in
            self?.view.layer.opacity = .one
          }
        }
      )
    }
  }
}
