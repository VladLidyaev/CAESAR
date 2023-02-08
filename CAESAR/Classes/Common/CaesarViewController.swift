// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import UIKit

// MARK: - CaesarViewController

class CaesarViewController: UIViewController {
  // MARK: - Properties

  var manager: CaesarManager?

  // MARK: - Initialization

  init() {
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
