// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation
import FirebaseDatabase

// MARK: - DatabaseProvider

class DatabaseProvider {
  // MARK: - Properties

  private var mainReference: DatabaseReference

  // MARK: - Computed variables

  // MARK: - Constraints

  // MARK: - Initialization

  init() {
    mainReference = Database.database().reference()
  }

  // MARK: - Public Methods

  func getConfig(
    onSuccess: @escaping (ConfigDTO) -> Void,
    onError: @escaping (Error?) -> Void
  ) {
    mainReference.child(
      path([ConfigDTO.key])
    ).getData { error, snapshot in
      guard let snapshot = snapshot else {
        onError(error)
        return
      }

      guard
        let dictionary = snapshot.value as? Dictionary<String, Any>,
        let configDTO = ConfigDTO(from: dictionary)
      else {
        onError(LocalError.unableToGetConfig)
        return
      }

      onSuccess(configDTO)
    }
  }

  func getUser(
    userID: String,
    onSuccess: @escaping (UserDTO?) -> Void,
    onError: @escaping (Error?) -> Void
  ) {
    mainReference.child(
      path([UserDTO.key, userID])
    ).getData { error, snapshot in
      guard let snapshot = snapshot else {
        onError(error)
        return
      }

      guard let dictionary = snapshot.value as? Dictionary<String, Any> else {
        onSuccess(nil)
        return
      }
      
      onSuccess(UserDTO(from: dictionary))
    }
  }

  func updateUser(
    dto: UserDTO,
    onSuccess: @escaping () -> Void,
    onError: @escaping (Error?) -> Void
  ) {
    mainReference.updateChildValues([
      path([UserDTO.key, dto.id]): dto.asDictionary
    ]) { error, _ in
      guard error == nil else {
        onError(error)
        return
      }
      onSuccess()
    }
  }

  func deleteChatRequest(
    chatRequestID: String,
    onSuccess: @escaping () -> Void,
    onError: @escaping (Error?) -> Void
  ) {
    mainReference.child(
      path([ChatRequestDTO.key, chatRequestID])
    ).removeValue { error, _ in
      guard error == nil else {
        onError(error)
        return
      }
      onSuccess()
    }
  }

  func deleteChat(
    chatID: String,
    onSuccess: @escaping () -> Void,
    onError: @escaping (Error?) -> Void
  ) {
    mainReference.child(
      path([ChatDTO.key, chatID])
    ).removeValue { error, _ in
      guard error == nil else {
        onError(error)
        return
      }
      onSuccess()
    }
  }

  func deleteMessages(
    chatID: String,
    onSuccess: @escaping () -> Void,
    onError: @escaping (Error?) -> Void
  ) {
    mainReference.child(
      path([MessageDTO.key, chatID])
    ).removeValue { error, _ in
      guard error == nil else {
        onError(error)
        return
      }
      onSuccess()
    }
  }

  func createChatRequest(
    userDTO: UserDTO,
    chatRequestDTO: ChatRequestDTO,
    onSuccess: @escaping () -> Void,
    onError: @escaping (Error?) -> Void
  ) {
    mainReference.updateChildValues([
      path([ChatRequestDTO.key, chatRequestDTO.id]): chatRequestDTO.asDictionary
    ]) { [weak self] error, _ in
      guard error == nil else {
        onError(error)
        return
      }

      self?.updateUser(
        dto: userDTO,
        onSuccess: onSuccess,
        onError: onError
      )
    }
  }

  // MARK: - Private Methods

  func path(_ array: [String]) -> String {
    let formatAction: (String) -> (String) = { string in "/\(string)" }
    var result: String = .empty
    array.forEach { result += formatAction($0) }
    return result
  }
}

// MARK: - LocalConstants

private enum LocalConstants {

}
