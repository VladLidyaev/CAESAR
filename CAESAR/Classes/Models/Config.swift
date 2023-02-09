// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation

// MARK: - Config

class Config {
  // MARK: - Properties

  private let minSupportedVersion: Float
  private let chatRequestTTL: UInt64

  // MARK: - Initialization

  init(dto: ConfigDTO) {
    self.minSupportedVersion = dto.min_supported_version
    self.chatRequestTTL = dto.chat_request_ttl
  }

  // MARK: - Public Methods

  func isVersionAvailbale(_ version: Float) -> Bool {
    return version >= minSupportedVersion
  }

  func chatRequestTimer(completion: @escaping () -> Void) {
    let timeInterval = TimeInterval(chatRequestTTL)
    DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
      completion()
    }
  }
}
