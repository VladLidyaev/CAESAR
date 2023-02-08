// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation

// MARK: - Config

class Config {
  // MARK: - Properties

  let minSupportedVersion: Float
  let chatTTL: UInt64
  let chatRequestTTL: UInt64

  // MARK: - Initialization

  init(dto: ConfigDTO) {
    self.minSupportedVersion = dto.min_supported_version
    self.chatTTL = dto.chat_ttl
    self.chatRequestTTL = dto.chat_request_ttl
  }
}
