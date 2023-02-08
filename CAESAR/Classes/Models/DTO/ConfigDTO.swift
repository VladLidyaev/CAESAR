// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation

// MARK: - ConfigDTO

struct ConfigDTO {
  let min_supported_version: Float
  let chat_ttl: UInt64
  let chat_request_ttl: UInt64

  init?(from dictionary: Dictionary<String, Any>) {
    guard
      let min_supported_version = dictionary[Keys.min_supported_version.rawValue] as? Float,
      let chat_ttl = dictionary[Keys.chat_ttl.rawValue] as? UInt64,
      let chat_request_ttl = dictionary[Keys.chat_request_ttl.rawValue] as? UInt64
    else { return nil }

    self.min_supported_version = min_supported_version
    self.chat_ttl = chat_ttl
    self.chat_request_ttl = chat_request_ttl
  }
}

// MARK: - Keys

extension ConfigDTO {
  static let key: String = "config"

  enum Keys: String {
    case min_supported_version
    case chat_ttl
    case chat_request_ttl
  }
}
