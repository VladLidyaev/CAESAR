// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation

// MARK: - Strings

enum Strings {

  // MARK: - ErrorViewController

  enum ErrorViewController {
    static let title = "ERROR"
    static let message = "An unknown error has occurred. Restart or reinstall the app."
  }

  // MARK: - ClosedChatAlert

  enum ClosedChatAlert {
    static let title = "CHAT ENDED"
    static let message = "Restart app to start a new chat."
  }

  // MARK: - StartChatViewController

  enum StartChatViewController {
    static let title = "CHAT REQUEST"
    static func message(code: String?) -> String { "User with code: \(code ?? noneCode) wants to open a chat with you." }
    static let acceptButtonTitle = "Accept"
    static let declineButtonTitle = "Decline"
    private static let noneCode = "NONE"
  }

  // MARK: - WelcomeViewController

  enum WelcomeViewController {
    static let titleLabelText = "ENTER THE COMPANION CODE:"
    static let subtitleLabelText = "YOUR CODE:"
    static let displayNameLabelText = "Your nickname: "
  }

  // MARK: - ImagePickerController

  enum ImagePickerController {
    static let cameraLabelText = "Camera"
    static let libraryLabelText = "Library"
    static let cancelLabelText = "Cancel"
  }


  // MARK: - LocalAuthenticationContext

  enum LocalAuthenticationContext {
    static let reason = "Authentication required"
  }

  // MARK: - DatesShorts

  enum DatesShorts {
    static let year = "y"
    static let month = "m"
    static let week = "w"
    static let day = "d"
    static let hour = "h"
    static let minute = "min"
    static let second = "sec"
    static let justNow = "Just now"
  }
}
