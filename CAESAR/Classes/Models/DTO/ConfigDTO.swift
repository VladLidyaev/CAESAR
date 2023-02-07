// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation

// MARK: - ConfigDTO

struct ConfigDTO {
  let min_supported_version: Float
  let chat_ttl: UInt64
  let chat_request_ttl: UInt64

  init?(
    min_supported_version: NSNumber?,
    chat_ttl: NSNumber?,
    chat_request_ttl: NSNumber?
  ) {
    guard
      let min_supported_version = min_supported_version as? Float,
      let chat_ttl = chat_ttl as? UInt64,
      let chat_request_ttl = chat_request_ttl as? UInt64
    else { return nil }

    self.min_supported_version = min_supported_version
    self.chat_ttl = chat_ttl
    self.chat_request_ttl = chat_request_ttl
  }
}

// MARK: - Keys

extension ConfigDTO {
  enum Keys: String {
    case min_supported_version
    case chat_ttl
    case chat_request_ttl
  }
}
