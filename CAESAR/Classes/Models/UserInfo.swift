// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation
import CryptoKit

// MARK: - UserInfo

class UserInfo {
  // MARK: - Properties

  var chatRequestDTO: ChatRequestDTO?
  var chatDTO: ChatDTO?
  var companionUserDTO: UserDTO?
  var userDTO: UserDTO {
    UserDTO(
      id: userID,
      public_key: privateKey.publicKey.rawRepresentation,
      display_name: displayName,
      chat_request_id: chatRequestDTO?.id,
      chat_id: chatDTO?.id
    )
  }

  private let userID: String
  private let displayName: String
  private let privateKey: SecureEnclave.P256.KeyAgreement.PrivateKey
  private var symmetricKey: SymmetricKey?

  // MARK: - Initialization

  init(
    userID: String,
    displayName: String = Strings.UserInfo.defaultDisplayName + .init(
      randomCharactersLength: Constants.Core.nicknameCodeLength
    ),
    privateKey: SecureEnclave.P256.KeyAgreement.PrivateKey
  ) {
    self.userID = userID
    self.displayName = displayName
    self.privateKey = privateKey
  }

  func textToData(
    _ text: String,
    onSuccess: (Data) -> Void,
    onError: () -> Void
  ) {
    guard
      SecureEnclave.isAvailable,
      let symmetricKey = symmetricKey,
      let data = text.data(using: .utf8),
      let box = try? ChaChaPoly.seal(data, using: symmetricKey).combined
    else {
      onError()
      return
    }
    onSuccess(box)
  }

  func dataToText(
    _ data: Data,
    onSuccess: (String) -> Void,
    onError: () -> Void
  ) {
    guard
      SecureEnclave.isAvailable,
      let symmetricKey = symmetricKey,
      let box = try? ChaChaPoly.SealedBox(combined: data),
      let textData = try? ChaChaPoly.open(box, using: symmetricKey),
      let text = String(data: textData, encoding: .utf8)
    else {
      onError()
      return
    }
    onSuccess(text)
  }

  func setCompanionPublicKeyData(
    _ data: Data,
    saltString: String,
    onSuccess: () -> Void,
    onError: () -> Void
  ) {
    guard
      SecureEnclave.isAvailable,
      let companionPublicKey = try? P256.KeyAgreement.PublicKey(rawRepresentation: data),
      let sharedSecret = try? privateKey.sharedSecretFromKeyAgreement(with: companionPublicKey),
      let salt = saltString.data(using: .utf8)
    else {
      onError()
      return
    }

    onSuccess()
    symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
      using: SHA256.self,
      salt: salt,
      sharedInfo: Data(),
      outputByteCount: Constants.Core.outputByteCount
    )
  }
}
