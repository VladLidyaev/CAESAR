// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation

// MARK: - Config

class Config {
  // MARK: - Properties

  let version: Float
  let chatTTL: UInt64
  let chatRequestTTL: UInt64

  // MARK: - Computed variables

  // MARK: - Initialization

  init(dto: ConfigDTO) {
    self.version = dto.version
    self.chatTTL = dto.chat_ttl
    self.chatRequestTTL = dto.chat_request_ttl
  }
}
