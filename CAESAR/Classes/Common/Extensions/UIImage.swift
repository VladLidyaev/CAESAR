// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import UIKit

// MARK: - Image To String Converter

extension UIImage {
  func toString() -> String? {
    guard let maxData = self.jpegData(compressionQuality: .one) else { return nil }
    var compressionQualityCoeff: CGFloat = CGFloat(maxData.count / Constants.Core.maxImageBytesCount)
    compressionQualityCoeff = max(.zero, min(.one, compressionQualityCoeff))
    return self
      .jpegData(compressionQuality: compressionQualityCoeff)?
      .base64EncodedString(options: .endLineWithLineFeed)
  }
}

