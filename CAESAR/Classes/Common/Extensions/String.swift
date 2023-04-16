// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import UIKit

// MARK: - Empty

extension String {
  static let empty: String = ""
}

// MARK: - containsOnlyWhitespacesAndNewlines

extension String {
  var containsOnlyWhitespacesAndNewlines: Bool {
    trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }
}

// MARK: - Empty

extension String {
  init(randomCharactersLength: Int) {
    var chatRequestID: String = .empty
    for _ in .zero...randomCharactersLength - 1 {
      chatRequestID += String(Int.random(in: .zero...9))
    }
    self = chatRequestID
  }
}

// MARK: - WithSpacings

extension String {
  var withSpacings: String {
    let spacerCount: Int = 5
    let spacingCharacter = "     "
    var result: String = .empty
    self.forEach { result += spacingCharacter + String($0) }
    result.removeFirst(spacerCount)
    return result
  }
}

// MARK: - String To Image Converter

extension String {
  func toImage() -> UIImage? {
    guard let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else { return nil }
    return UIImage(data: data)
  }
}
