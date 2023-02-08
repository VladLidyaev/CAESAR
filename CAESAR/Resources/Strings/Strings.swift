// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation

// MARK: - Strings

enum Strings {

  // MARK: - ErrorViewController

  enum ErrorViewController {
    static let title = "ERROR"
    static let message = "An unknown error has occurred. Restart or reinstall the app."
  }

  // MARK: - StartChatViewController

  enum StartChatViewController {
    static let title = "CHAT REQUEST"
    static func message(userName: String) -> String { "User \(userName) wants to open a chat with you." }
    static let acceptButtonTitle = "Accept"
    static let declineButtonTitle = "Decline"
  }

  // MARK: - LocalAuthenticationContext

  enum LocalAuthenticationContext {
    static let reason = "Authentication required"
  }

  // MARK: - UserInfo

  enum UserInfo {
    static let defaultDisplayName = "Unkown"
  }
}
