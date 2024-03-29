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
    DispatchQueue.main.async { [weak self] in
      self?.present(alert, animated: true, completion: nil)
    }
  }
}


// MARK: - ClosedChatAlert

extension UIViewController {
  func showClosedChatAlert() {
    let alert = UIAlertController(
      title: Strings.ClosedChatAlert.title,
      message: Strings.ClosedChatAlert.message,
      preferredStyle: .alert
    )
    DispatchQueue.main.async { [weak self] in
      self?.present(alert, animated: true, completion: nil)
    }
  }
}

// MARK: - ImagePickerAlert

extension UIViewController {
  func showImagePickerAlert(
    showImagePicker: @escaping (UIImagePickerController.SourceType) -> Void
  ) {
    let alert = UIAlertController(
      title: nil,
      message: nil,
      preferredStyle: .actionSheet
    )

    let cameraAction = UIAlertAction(
      title: Strings.ImagePickerController.cameraLabelText,
      style: .default
    ) { _ in
      showImagePicker(.camera)
    }
    alert.addAction(cameraAction)

    let libraryAction = UIAlertAction(
      title: Strings.ImagePickerController.libraryLabelText,
      style: .default
    ) { _ in
      showImagePicker(.photoLibrary)
    }
    alert.addAction(libraryAction)

    let cancelAction = UIAlertAction(
      title: Strings.ImagePickerController.cancelLabelText,
      style: .cancel,
      handler: nil
    )
    alert.addAction(cancelAction)

    DispatchQueue.main.async { [weak self] in
      self?.present(alert, animated: true, completion: nil)
    }
  }
}

// MARK: - StartChatAlert

extension UIViewController {
  func showStartChatAlert(
    code: String?,
    acceptAction: @escaping () -> Void,
    declineAction: @escaping () -> Void,
    completion: @escaping (@escaping () -> Void) -> Void
  ) {
    let alert = UIAlertController(
      title: Strings.StartChatViewController.title,
      message: Strings.StartChatViewController.message(code: code),
      preferredStyle: .alert
    )
    alert.addAction(
      .init(
        title: Strings.StartChatViewController.acceptButtonTitle,
        style: .default,
        handler: { _ in acceptAction() }
      )
    )
    alert.addAction(
      .init(
        title: Strings.StartChatViewController.declineButtonTitle,
        style: .destructive,
        handler: { _ in declineAction() }
      )
    )

    completion({
      DispatchQueue.main.async {
        alert.dismiss(animated: true)
      }
    })
    
    DispatchQueue.main.async { [weak self] in
      self?.present(alert, animated: true, completion: nil)
    }
  }
}

// MARK: - WaitingAlert

extension UIViewController {
  func waitingAlert(
    completion: @escaping (@escaping () -> Void) -> Void
  ) {
    let alert = UIAlertController(title: .empty, message: nil, preferredStyle: .alert)
    let indicator = UIActivityIndicatorView(frame: alert.view.bounds)
    alert.view.addSubview(indicator)

    indicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    indicator.isUserInteractionEnabled = false
    indicator.startAnimating()

    completion({
      DispatchQueue.main.async {
        alert.dismiss(animated: true)
      }
    })
    DispatchQueue.main.async { [weak self] in
      self?.present(alert, animated: true, completion: nil)
    }
  }
}

// MARK: - Present With Dimm Animation

extension UIViewController {
  func present(_ viewContrtoller: UIViewController, completion: @escaping () -> Void) {
    DispatchQueue.main.async { [weak self] in
      viewContrtoller.modalPresentationStyle = .fullScreen
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
              completion()
              self?.removeFromParent()
            }
          }
        )
      }
    }
  }
}
