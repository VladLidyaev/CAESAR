// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import UIKit

// MARK: - CaesarViewController

class CaesarViewController: UIViewController {
  // MARK: - Properties

  var manager: CaesarManager?
  let toolbar = UIToolbar()

  // MARK: - Initialization

  init() {
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupTextFields()
  }

  func setupTextFields() {
    let flexSpace = UIBarButtonItem(
      barButtonSystemItem: .flexibleSpace,
      target: nil, action: nil
    )
    let doneButton = UIBarButtonItem(
      title: "Done", style: .done,
      target: self, action: #selector(doneButtonTapped)
    )
    toolbar.setItems([flexSpace, doneButton], animated: true)
    toolbar.sizeToFit()
  }

  @objc func doneButtonTapped() {
    view.endEditing(true)
  }
}
