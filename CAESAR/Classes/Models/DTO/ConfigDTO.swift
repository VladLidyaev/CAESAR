// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation

// MARK: - ConfigDTO

struct ConfigDTO {
  let version: Float
  let code_ttl: UInt64
  let chat_ttl: UInt64
  let chat_request_ttl: UInt64

  init?(
    version: NSNumber?,
    code_ttl: NSNumber?,
    chat_ttl: NSNumber?,
    chat_request_ttl: NSNumber?
  ) {
    guard
      let version = version as? Float,
      let code_ttl = code_ttl as? UInt64,
      let chat_ttl = chat_ttl as? UInt64,
      let chat_request_ttl = chat_request_ttl as? UInt64
    else { return nil }
    
    self.version = version
    self.code_ttl = code_ttl
    self.chat_ttl = chat_ttl
    self.chat_request_ttl = chat_request_ttl
  }
}

// MARK: - Keys

extension ConfigDTO {
  enum Keys: String {
    case version
    case code_ttl
    case chat_ttl
    case chat_request_ttl
  }
}

// MARK: - Comparable

extension ConfigDTO: Comparable {
  static func < (lhs: ConfigDTO, rhs: ConfigDTO) -> Bool {
    lhs.version < rhs.version
  }
}
