// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation
import CryptoKit

// MARK: - UserInfo

class UserInfo {
  // MARK: - Properties

  private let userID: String
  private let privateKey: SecureEnclave.P256.KeyAgreement.PrivateKey

  // MARK: - Initialization

  init(
    userID: String,
    privateKey: SecureEnclave.P256.KeyAgreement.PrivateKey
  ) {
    self.userID = userID
    self.privateKey = privateKey
  }

  // MARK: - Public Methods

  // MARK: - Private Methods
}
