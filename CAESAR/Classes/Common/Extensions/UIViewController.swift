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
