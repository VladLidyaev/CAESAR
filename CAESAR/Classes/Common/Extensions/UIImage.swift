// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import UIKit

// MARK: - Image To String Converter

extension UIImage {
  func toString() -> String? {
    let data = self.pngData()
    return data?.base64EncodedString(options: .endLineWithLineFeed)
  }
}
