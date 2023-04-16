// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import UIKit

class ImagePicker: NSObject {
  private let pickerController: UIImagePickerController
  private var completionHandler: ((UIImage?) -> Void)?

  override init() {
    self.pickerController = UIImagePickerController()
    super.init()
    self.pickerController.delegate = self
  }

  func present(
    from viewController: UIViewController,
    sourceType: UIImagePickerController.SourceType,
    completionHandler: @escaping (UIImage?) -> Void
  ) {
    self.pickerController.sourceType = sourceType
    self.completionHandler = completionHandler
    viewController.present(self.pickerController, animated: true)
  }
}

extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    self.pickerController.dismiss(animated: true, completion: nil)
  }

  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
    self.completionHandler?(image)
    self.pickerController.dismiss(animated: true, completion: nil)
  }
}
