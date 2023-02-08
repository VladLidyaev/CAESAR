// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation
import CryptoKit

// MARK: - UserInfo

class UserInfo {
  // MARK: - Properties

  private let userID: String
  private var chatRequestID: String?
  private var chatID: String?
  private let displayName: String
  private let privateKey: SecureEnclave.P256.KeyAgreement.PrivateKey

  var publicKey: P256.KeyAgreement.PublicKey {
    privateKey.publicKey
  }

  var userDTO: UserDTO {
    UserDTO(
      id: userID,
      public_key: publicKey.rawRepresentation,
      display_name: displayName,
      chat_request_id: chatRequestID,
      chat_id: chatID
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

  func setChatRequestID(_ value: String) {
    chatRequestID = value
  }

  func setChatID(_ value: String) {
    chatID = value
  }

  // MARK: - Private Methods
}
