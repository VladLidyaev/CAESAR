// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import UIKit
import FirebaseAuth

class LaunchViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    Auth.auth().signInAnonymously { authResult, error in
      guard let result = authResult else { return }
      
    }
  }
}
