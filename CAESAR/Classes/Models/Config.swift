// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation

// MARK: - Config

class Config {
  // MARK: - Properties

  private let minSupportedVersion: Float
  private let chatTTL: UInt64
  private let chatRequestTTL: UInt64

  // MARK: - Initialization

  init(dto: ConfigDTO) {
    self.minSupportedVersion = dto.min_supported_version
    self.chatTTL = dto.chat_ttl
    self.chatRequestTTL = dto.chat_request_ttl
  }

  // MARK: - Public Methods

  func isVersionAvailbale(_ version: Float) -> Bool {
    return version >= minSupportedVersion
  }

  // MARK: - Private Methods
}
