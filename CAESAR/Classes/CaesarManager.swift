// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation
import UIKit
import CryptoKit

// MARK: - CaesarManagerState

enum CaesarManagerState {
  case welcome
  case chatting

  var isWelcomeScreen: Bool {
    switch self {
    case .welcome:
      return true
    default:
      return false
    }
  }

  var isChatScreen: Bool {
    switch self {
    case .chatting:
      return true
    default:
      return false
    }
  }
}

// MARK: - CaesarManager

class CaesarManager {
  // MARK: - Properties

  private let userInfo: UserInfo
  private let databaseProvider: DatabaseProvider
  private var state: CaesarManagerState = .welcome
  private weak var actualViewController: CaesarViewController?

  var config: Config? {
    didSet {
      checkAppVersion()
    }
  }

  var chatRequestID: String? {
    userInfo.chatRequestDTO?.id
  }

  var displayName: String {
    userInfo.userDTO.display_name
  }

  // MARK: - Computed variables

  // MARK: - Constraints

  // MARK: - Initialization
  
  init(
    userInfo: UserInfo,
    viewController: LaunchViewController
  ) {
    self.userInfo = userInfo
    self.actualViewController = viewController
    self.databaseProvider = DatabaseProvider()
  }

  // MARK: - Public Methods

  func launch() {
    let onError: (Error?) -> () = { [weak self] error in
      self?.handleError(error)
    }

    updateConfig(
      onSuccess: { [weak self] in
        self?.updateState(
          onSuccess: {
            self?.createChatRequest(
              onSuccess: {
                self?.presentVC(
                  self?.makeWelcomeViewController()
                )
              },
              onError: onError
            )
          },
          onError: onError
        )
      },
      onError: onError
    )
  }

  func subscribeOnCompanion(
    onSuccess: @escaping (UserDTO) -> Void
  ) {
    let onError: (Error?) -> () = { [weak self] error in
      guard self?.state.isWelcomeScreen == true else { return }
      self?.handleError(error)
    }

    guard let chatRequestID = userInfo.chatRequestDTO?.id else {
      onError(nil)
      return
    }

    databaseProvider.subscribeOnCompanionID(
      chatRequestID: chatRequestID,
      onSuccess: { [weak self] companionID in
        self?.databaseProvider.getUser(
          userID: companionID,
          onSuccess: { userDTO in
            guard let userDTO = userDTO else {
              onError(nil)
              return
            }

            guard self?.state.isWelcomeScreen == true else { return }
            onSuccess(userDTO)
          },
          onError: onError
        )
      },
      onError: onError
    )
  }

  func subscribeOnChat(
    chatRequestID: String,
    onSuccess: @escaping (ChatDTO) -> Void
  ) {
    let onError: (Error?) -> () = { [weak self] error in
      guard self?.state.isWelcomeScreen == true else { return }
      self?.handleError(error)
    }

    databaseProvider.subscribeOnChatID(
      chatRequestID: chatRequestID,
      onSuccess: { [weak self] chatID in
        self?.databaseProvider.getChat(
          chatID: chatID,
          onSuccess: { chatDTO in
            onSuccess(chatDTO)
          },
          onError: onError
        )
      },
      onError: onError
    )
  }

  func requestChat(chatRequestID: String) {
    databaseProvider.updateChatRequestCompanionID(
      chatRequestID: chatRequestID,
      companionID: userInfo.userDTO.id,
      onSuccess: {},
      onError: { [weak self] error in
        self?.handleError(error)
      }
    )
  }

  func declineChatRequest() {
    let onError: (Error?) -> () = { [weak self] error in
      self?.handleError(error)
    }

    guard let chatRequestID = userInfo.chatRequestDTO?.id else {
      onError(nil)
      return
    }

    databaseProvider.updateChatRequestCompanionID(
      chatRequestID: chatRequestID,
      companionID: nil,
      onSuccess: {},
      onError: onError
    )
  }

  func acceptChatRequest(
    with companionID: String,
    onSuccess: @escaping (ChatDTO) -> Void
  ) {
    let onError: (Error?) -> () = { [weak self] error in
      self?.handleError(error)
    }

    guard let chatRequestID = userInfo.chatRequestDTO?.id else {
      onError(nil)
      return
    }

    let chatDTO = ChatDTO(
      chat_request_id: chatRequestID,
      user_id: userInfo.userDTO.id,
      companion_id: companionID
    )

    deleteSubscribeOnCompanion()
    databaseProvider.createChat(
      chatDTO: chatDTO,
      chatRequestID: chatRequestID,
      onSuccess: { [weak self] in
        self?.databaseProvider.updateChatRequestChatID(
          chatRequestID: chatRequestID,
          chatID: chatDTO.id,
          onSuccess: {
            onSuccess(chatDTO)
          },
          onError: onError
        )
      },
      onError: onError
    )
  }

  func deleteSubscribeOnChat(chatRequestID: String) {
    databaseProvider.deleteSubscribeOnChatID(chatRequestID: chatRequestID)
  }

  func deleteSubscribeOnCompanion() {
    guard let chatRequestID = userInfo.chatRequestDTO?.id else { return }
    databaseProvider.deleteSubscribeOnCompanionID(chatRequestID: chatRequestID)
  }


  func startChat(chatDTO: ChatDTO) {
    state = .chatting
    userInfo.chatDTO = chatDTO
    presentVC(makeChatViewController())
  }

  // MARK: - Private Methods

  private func updateConfig(
    onSuccess: @escaping () -> Void,
    onError: @escaping (Error?) -> Void
  ) {
    databaseProvider.getConfig(
      onSuccess: { [weak self] configDTO in
        self?.config =  Config(dto: configDTO)
        onSuccess()
      },
      onError: onError
    )
  }

  private func checkAppVersion() {
    guard let config = config else {
      handleError()
      return
    }

    guard config.isVersionAvailbale(SystemProvider.bundleVersion) else {
      handleError(LocalError.unsupportedAppVersion)
      return
    }
  }

  private func updateState(
    onSuccess: @escaping () -> Void,
    onError: @escaping (Error?) -> Void
  ) {
    databaseProvider.getUser(
      userID: userInfo.userDTO.id,
      onSuccess: { [weak self] userDTO in
        self?.deleteChatRequestIfNeeded(
          chatRequestID: userDTO?.chat_request_id,
          onSuccess: {
            self?.deleteChatsIfNeeded(
              chatID: userDTO?.chat_id,
              onSuccess: {
                self?.deleteMessagesIfNeeded(
                  chatID: userDTO?.chat_id,
                  onSuccess: {
                    self?.updateUser(
                      onSuccess: onSuccess,
                      onError: onError
                    )
                  },
                  onError: onError
                )
              },
              onError: onError
            )
          },
          onError: onError
        )
      },
      onError: onError
    )
  }

  private func updateUser(
    onSuccess: @escaping () -> Void,
    onError: @escaping (Error?) -> Void
  ) {
    databaseProvider.updateUser(
      dto: userInfo.userDTO,
      onSuccess: onSuccess,
      onError: onError
    )
  }

  private func deleteChatRequestIfNeeded(
    chatRequestID: String?,
    onSuccess: @escaping () -> Void,
    onError: @escaping (Error?) -> Void
  ) {
    guard let chatRequestID = chatRequestID else {
      onSuccess()
      return
    }

    databaseProvider.deleteChatRequest(
      chatRequestID: chatRequestID,
      onSuccess: onSuccess,
      onError: onError
    )
  }

  private func deleteChatsIfNeeded(
    chatID: String?,
    onSuccess: @escaping () -> Void,
    onError: @escaping (Error?) -> Void
  ) {
    guard let chatID = chatID else {
      onSuccess()
      return
    }

    databaseProvider.deleteChat(
      chatID: chatID,
      onSuccess: onSuccess,
      onError: onError
    )
  }

  private func deleteMessagesIfNeeded(
    chatID: String?,
    onSuccess: @escaping () -> Void,
    onError: @escaping (Error?) -> Void
  ) {
    guard let chatID = chatID else {
      onSuccess()
      return
    }

    databaseProvider.deleteMessages(
      chatID: chatID,
      onSuccess: onSuccess,
      onError: onError
    )
  }

  private func createChatRequest(
    onSuccess: @escaping () -> Void,
    onError: @escaping (Error?) -> Void
  ) {
    let chatRequestDTO = ChatRequestDTO(
      id: generateChatRequestID(),
      user_id: userInfo.userDTO.id
    )
    userInfo.chatRequestDTO = chatRequestDTO
    databaseProvider.createChatRequest(
      userDTO: userInfo.userDTO,
      chatRequestDTO: chatRequestDTO,
      onSuccess: onSuccess,
      onError: onError
    )
  }

  // MARK: - UI

  private func presentVC(_ viewController: CaesarViewController?) {
    guard
      let viewController = viewController,
      let actualViewController = actualViewController
    else { return }
    viewController.manager = self
    actualViewController.present(viewController) { [weak self] in
      self?.actualViewController = viewController
    }
  }

  private func makeWelcomeViewController() -> WelcomeViewController {
    WelcomeViewController()
  }

  private func makeChatViewController() -> ChatViewController {
    ChatViewController()
  }

  // MARK: - Helpers

  private func generateChatRequestID() -> String {
    var chatRequestID: String = .empty
    for _ in .zero...Constants.Core.chatRequestIDLength - 1 {
      chatRequestID += String(Int.random(in: .zero...9))
    }
    return chatRequestID
  }

  // MARK: - Error Handling

  private func handleError(_ error: Error? = nil) {
    guard let actualViewController = actualViewController else { return }
    actualViewController.showErrorAlert(message: error?.localizedDescription)
  }
}

// MARK: - LocalConstants

private enum LocalConstants {

}
