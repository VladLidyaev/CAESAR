// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation

// MARK: - Empty

extension String {
  static let empty: String = ""
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
