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

  // MARK: - Get Config

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

  // MARK: - GetUser

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

  // MARK: - GetChat

  func getChat(
    chatID: String,
    onSuccess: @escaping (ChatDTO) -> Void,
    onError: @escaping (Error?) -> Void
  ) {
    mainReference.child(
      path([ChatDTO.key, chatID])
    ).getData { error, snapshot in
      guard let snapshot = snapshot else {
        onError(error)
        return
      }

      guard
        let dictionary = snapshot.value as? Dictionary<String, Any>,
        let chatDTO = ChatDTO(from: dictionary)
      else {
        onError(nil)
        return
      }
      onSuccess(chatDTO)
    }
  }

  // MARK: - GetChatRequest

  func getChatRequest(
    chatRequestID: String,
    onSuccess: @escaping (ChatRequestDTO?) -> Void,
    onError: @escaping (Error?) -> Void
  ) {
    mainReference.child(
      path([ChatRequestDTO.key, chatRequestID])
    ).getData { error, snapshot in
      guard let snapshot = snapshot else {
        onError(error)
        return
      }

      guard let dictionary = snapshot.value as? Dictionary<String, Any> else {
        onSuccess(nil)
        return
      }

      onSuccess(ChatRequestDTO(from: dictionary))
    }
  }

  // MARK: - CreateChatRequest

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

  // MARK: - CreateChat

  func createChat(
    chatDTO: ChatDTO,
    chatRequestID: String,
    onSuccess: @escaping () -> Void,
    onError: @escaping (Error?) -> Void
  ) {
    mainReference.updateChildValues([
      path([ChatDTO.key, chatDTO.id]): chatDTO.asDictionary
    ]) { [weak self] error, _ in
      guard error == nil else {
        onError(error)
        return
      }

      self?.updateChatRequestChatID(
        chatRequestID: chatRequestID,
        chatID: chatDTO.id,
        onSuccess: onSuccess,
        onError: onError
      )
    }
  }

  // MARK: - UpdateUser

  func updateUser(
    dto: UserDTO,
    onSuccess: @escaping () -> Void,
    onError: @escaping (Error?) -> Void
  ) {
    mainReference.child(
      path([UserDTO.key, dto.id])
    ).setValue(dto.asDictionary) { error, _ in
      guard error == nil else {
        onError(error)
        return
      }
      onSuccess()
    }
  }

  // MARK: - UpdateChatRequestChatID

  func updateChatRequestChatID(
    chatRequestID: String,
    chatID: String,
    onSuccess: @escaping () -> Void,
    onError: @escaping (Error?) -> Void
  ) {
    mainReference.child(
      path([ChatRequestDTO.key, chatRequestID, ChatRequestDTO.Keys.chat_id.rawValue])
    ).setValue(chatID) { error, _ in
      guard error == nil else {
        onError(error)
        return
      }
      onSuccess()
    }
  }

  // MARK: - UpdateChatRequestCompanionID

  func updateChatRequestCompanionID(
    chatRequestID: String,
    companionID: String?,
    onSuccess: @escaping () -> Void,
    onError: @escaping (Error?) -> Void
  ) {
    getChatRequest(
      chatRequestID: chatRequestID,
      onSuccess: { [weak self] chatRequestDTO in
        guard let _ = chatRequestDTO, let self = self else {
          onSuccess()
          return
        }

        if let companionID = companionID {
          self.mainReference.updateChildValues([
            self.path([ChatRequestDTO.key, chatRequestID, ChatRequestDTO.Keys.companion_id.rawValue]): companionID
          ]) { error, _ in
            guard error == nil else {
              onError(error)
              return
            }
            onSuccess()
          }
        } else {
          self.mainReference.child(
            self.path([ChatRequestDTO.key, chatRequestID, ChatRequestDTO.Keys.companion_id.rawValue])
          ).removeValue { error, _ in
            guard error == nil else {
              onError(error)
              return
            }
            onSuccess()
          }
        }
      },
      onError: onError
    )
  }

  // MARK: - DeleteChatRequest

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

  // MARK: - DeleteChat

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

  // MARK: - DeleteMessages

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

  // MARK: - SubscribeOnCompanionID

  func subscribeOnCompanionID(
    chatRequestID: String,
    onSuccess: @escaping (String) -> Void,
    onError: @escaping (Error?) -> Void
  ) {
    mainReference.child(
      path([ChatRequestDTO.key, chatRequestID, ChatRequestDTO.Keys.companion_id.rawValue])
    ).observe(.value, with: { snapshot in
      guard let value = snapshot.value else {
        onError(nil)
        return
      }

      guard let userID = value as? String else { return }
      onSuccess(userID)
    })
  }

  func deleteSubscribeOnCompanionID(chatRequestID: String) {
    mainReference.child(
      path([ChatRequestDTO.key, chatRequestID, ChatRequestDTO.Keys.companion_id.rawValue])
    ).removeAllObservers()
  }

  // MARK: - SubscribeOnChatID

  func subscribeOnChatID(
    chatRequestID: String,
    onSuccess: @escaping (String) -> Void,
    onError: @escaping (Error?) -> Void
  ) {
    mainReference.child(
      path([ChatRequestDTO.key, chatRequestID, ChatRequestDTO.Keys.chat_id.rawValue])
    ).observe(.value, with: { snapshot in
      guard let value = snapshot.value else {
        onError(nil)
        return
      }

      print(value)

      guard let chatID = value as? String else { return }
      onSuccess(chatID)
    })
  }

  func deleteSubscribeOnChatID(chatRequestID: String) {
    mainReference.child(
      path([ChatRequestDTO.key, chatRequestID, ChatRequestDTO.Keys.chat_id.rawValue])
    ).removeAllObservers()
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
