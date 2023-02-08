// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation

// MARK: - Empty

extension String {
  static let empty: String = ""
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
