// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation
import CryptoKit

// MARK: - UserInfo

class UserInfo {
  // MARK: - Properties

  private let userID: String
  private let displayName: String
  private let privateKey: SecureEnclave.P256.KeyAgreement.PrivateKey

  var publicKey: P256.KeyAgreement.PublicKey {
    privateKey.publicKey
  }

  var userDTO: UserDTO {
    UserDTO(
      id: userID,
      public_key: publicKey.rawRepresentation,
      display_name: displayName
    )
  }

  // MARK: - Initialization

  init(
    userID: String,
    displayName: String = Strings.UserInfo.defaultDisplayName,
    privateKey: SecureEnclave.P256.KeyAgreement.PrivateKey
  ) {
    self.userID = userID
    self.displayName = displayName
    self.privateKey = privateKey
  }

  // MARK: - Public Methods

  // MARK: - Private Methods
}
