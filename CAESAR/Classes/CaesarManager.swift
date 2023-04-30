// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation
import UIKit
import CryptoKit

// MARK: - CaesarManagerState

enum CaesarManagerState {
  case welcome
  case chatting
}

// MARK: - CaesarManager

class CaesarManager {
  // MARK: - Properties

  private let userInfo: UserInfo
  private let databaseProvider: DatabaseProvider
  private var state: CaesarManagerState = .welcome
  private var chatThrottler: Throttler?
  private weak var actualViewController: CaesarViewController?

  var config: Config? {
    didSet {
      checkAppVersion()
    }
  }

  var chatRequestID: String? {
    userInfo.chatRequestDTO?.id
  }

  // MARK: - Initialization
  
  init(
    userInfo: UserInfo,
    viewController: LaunchViewController
  ) {
    self.userInfo = userInfo
    self.actualViewController = viewController
    self.databaseProvider = DatabaseProvider()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(willResignActive),
      name: UIScene.willDeactivateNotification,
      object: nil
    )
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
      self?.handleError(error)
    }

    databaseProvider.subscribeOnChatID(
      chatRequestID: chatRequestID,
      onSuccess: { [weak self] chatID in
        self?.databaseProvider.getChat(
          chatID: chatID,
          onSuccess: { chatDTO in
            self?.userInfo.chatDTO = chatDTO
            self?.databaseProvider.getChatRequest(
              chatRequestID: chatRequestID,
              onSuccess: { chatRequestDTO in
                guard let userID = chatRequestDTO?.user_id else {
                  onError(nil)
                  return
                }

                self?.databaseProvider.getUser(
                  userID: userID,
                  onSuccess: { userDTO in
                    guard let userDTO = userDTO else {
                      onError(nil)
                      return
                    }

                    self?.userInfo.companionID = userDTO.id
                    self?.userInfo.setCompanionPublicKeyData(
                      userDTO.public_key,
                      saltString: chatID,
                      onSuccess: { onSuccess(chatDTO) },
                      onError: { onError(nil) }
                    )
                  },
                  onError: onError
                )
              },
              onError: onError
            )

            guard
              let userDTO = self?.userInfo.userDTO,
              let userChatRequestID = self?.userInfo.chatRequestDTO?.id
            else { return }
            self?.databaseProvider.updateUser(
              dto: userDTO,
              onSuccess: {},
              onError: onError
            )
            self?.databaseProvider.deleteChatRequest(
              chatRequestID: chatRequestID,
              onSuccess: {},
              onError: onError
            )
            self?.databaseProvider.deleteChatRequest(
              chatRequestID: userChatRequestID,
              onSuccess: {},
              onError: onError
            )
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

    userInfo.companionID = companionID
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
            self?.userInfo.chatDTO = chatDTO
            self?.databaseProvider.getUser(
              userID: companionID,
              onSuccess: { userDTO in
                guard let userDTO = userDTO else {
                  onError(nil)
                  return
                }

                self?.userInfo.setCompanionPublicKeyData(
                  userDTO.public_key,
                  saltString: chatDTO.id,
                  onSuccess: { onSuccess(chatDTO) },
                  onError: { onError(nil) }
                )
              },
              onError: onError
            )

            guard let userDTO = self?.userInfo.userDTO else { return }
            self?.databaseProvider.updateUser(
              dto: userDTO,
              onSuccess: {},
              onError: onError
            )
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

  func sendMessage(data: MessageData) {
    let onError: (Error?) -> () = { [weak self] error in
      self?.handleError(error)
    }

    guard
      let chatID = userInfo.chatDTO?.id,
      let stringData = try? JSONEncoder().encode(data),
      let string = String(data: stringData, encoding: .utf8)
    else {
      onError(nil)
      return
    }

    userInfo.stringToData(
      string,
      onSuccess: { [weak self] data in
        guard let self = self else { return }
        let messageDTO = MessageDTO(
          user_id: self.userInfo.userDTO.id,
          data: data
        )
        self.databaseProvider.createMessage(
          chatID: chatID,
          messageDTO: messageDTO,
          onSuccess: {},
          onError: onError
        )
      },
      onError: { onError(nil) }
    )
  }

  func subscribeOnMessages(onSuccess: @escaping ([Message]) -> Void) {
    let onError: (Error?) -> () = { [weak self] error in
      self?.handleError(error)
    }

    guard let chatID = userInfo.chatDTO?.id else { return }
    databaseProvider.subscribeOnMessages(
      chatID: chatID,
      onSuccess: { [weak self] dtoArray in
        var messages = [Message]()
        dtoArray.sorted { $0.timestamp < $1.timestamp }.forEach { dto in
          self?.makeMessage(
            dto: dto,
            onSuccess: { message in
              messages.append(message)
            },
            onError: { onError(nil) }
          )
        }
        self?.throttlingMesasages(messages)
        onSuccess(messages)
      },
      onError: onError
    )
  }

  func throttlingMesasages(_ messages: [Message]) {
    guard !messages.isEmpty else { return }
    chatThrottler?.cancel()
    chatThrottler?.throttle({ [weak self] in
      self?.handleError()
    })
  }

  func deleteMessage(with id: String) {
    guard let chatID = userInfo.chatDTO?.id else { return }
    databaseProvider.deleteMessage(
      chatID: chatID,
      messageId: id,
      onSuccess: {},
      onError: { _ in }
    )
  }

  func deleteAllInfo(withChatEndedNotification: Bool = false) {
    let onError: (Error?) -> () = { _ in }
    guard let companionID = userInfo.companionID else { return }

    databaseProvider.deleteUser(
      userID: userInfo.userDTO.id,
      onSuccess: { [weak self] in
        self?.databaseProvider.deleteUser(
          userID: companionID,
          onSuccess: {
            self?.deleteChatsIfNeeded(
              chatID: self?.userInfo.chatDTO?.id,
              onSuccess: {
                self?.deleteMessagesIfNeeded(
                  chatID: self?.userInfo.chatDTO?.id,
                  onSuccess: {
                    if withChatEndedNotification {
                      self?.actualViewController?.showClosedChatAlert()
                    }
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

  // MARK: - Private Methods

  private func makeMessage(
    dto: MessageDTO,
    onSuccess: (Message) -> Void,
    onError: () -> Void
  ) {
    userInfo.dataToString(
      dto.data,
      onSuccess: { string in
        guard
          let stringData = string.data(using: .utf8),
          let messageData = try? JSONDecoder().decode(MessageData.self, from: stringData)
        else {
          onError()
          return
        }

        onSuccess(
          Message(
            id: dto.id,
            data: messageData,
            isUserAutor: dto.user_id == userInfo.userDTO.id,
            timestamp: dto.timestamp
          )
        )
      },
      onError: onError
    )
  }

  private func updateConfig(
    onSuccess: @escaping () -> Void,
    onError: @escaping (Error?) -> Void
  ) {
    databaseProvider.getConfig(
      onSuccess: { [weak self] configDTO in
        self?.config =  Config(dto: configDTO)
        self?.chatThrottler = Throttler(interval: TimeInterval(configDTO.chat_ttl))
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
      id: .init(randomCharactersLength: Constants.Core.chatRequestIDLength),
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

  // MARK: - Error Handling

  private func handleError(_ error: Error? = nil) {
    guard let actualViewController = actualViewController else { return }
    switch state {
    case .welcome:
      actualViewController.showErrorAlert(message: error?.localizedDescription)
    case .chatting:
      actualViewController.showClosedChatAlert()
    }
  }

  // MARK: - WillResignActive

  @objc func willResignActive(_ notification: Notification) {
    guard state == .chatting else { return }
    deleteAllInfo()
  }
}
