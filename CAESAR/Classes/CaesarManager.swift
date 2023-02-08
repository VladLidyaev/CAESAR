// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation
import UIKit
import CryptoKit

// MARK: - CaesarManager

class CaesarManager {
  // MARK: - Properties

  weak var launchViewController: LaunchViewController? {
    didSet {
      actualViewController = launchViewController
    }
  }

  weak var welcomeViewController: UIViewController? {
    didSet {
      actualViewController = welcomeViewController
    }
  }

  weak var chatViewController: UIViewController? {
    didSet {
      actualViewController = chatViewController
    }
  }

  private var config: Config? {
    didSet {
      checkAppVersion()
    }
  }

  private let userInfo: UserInfo
  private let databaseProvider: DatabaseProvider
  private weak var actualViewController: UIViewController?

  // MARK: - Computed variables

  // MARK: - Constraints

  // MARK: - Initialization
  
  init(userInfo: UserInfo) {
    self.userInfo = userInfo
    self.databaseProvider = DatabaseProvider()
    updateConfig()
  }

  // MARK: - Public Methods

  func launch() {
    updateState { [weak self] in
      // TODO: -
    } onError: { [weak self] error in
      self?.handleError(error)
    }
  }

  // MARK: - Private Methods

  private func updateConfig() {
    databaseProvider.getConfig { [weak self] configDTO in
      self?.config =  Config(dto: configDTO)
    } onError: { [weak self] error in
      self?.handleError(error)
    }
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

  // MARK: - Error Handling

  private func handleError(_ error: Error? = nil) {
    guard let actualViewController = actualViewController else { return }
    actualViewController.showErrorAlert(message: error?.localizedDescription)
  }
}

// MARK: - LocalConstants

private enum LocalConstants {

}
