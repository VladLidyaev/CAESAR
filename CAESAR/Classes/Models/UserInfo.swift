// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation
import CryptoKit

// MARK: - UserInfo

class UserInfo {
  // MARK: - Properties

  private let id: String
  private let privateKey: P256.KeyAgreement.PrivateKey

  // MARK: - Initialization

  init(
    id: String,
    privateKey: P256.KeyAgreement.PrivateKey
  ) {
    self.id = id
    self.privateKey = privateKey
  }
}
