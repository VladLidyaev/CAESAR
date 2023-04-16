// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation

// MARK: - Constants

enum Constants {}

// MARK: - Core

extension Constants {
  enum Core {
    static let chatRequestIDLength: Int = 6
    static let nicknameCodeLength: Int = 4
    static let outputByteCount: Int = 32
  }
}

// MARK: - Animation

extension Constants {
  enum Animation {
    static let `default`: TimeInterval = 0.3
    static let extended: TimeInterval = `default` * 2
    static let accelerated: TimeInterval = `default` / 2
    static let blinking: TimeInterval = 1.0
  }
}

// MARK: - Colors

extension Constants {
  enum Colors {
    static let accent: String = "AccentColor"
    static let background: String = "BackgroundColor"
    static let textAndIcons: String = "TextAndIconsColor"
  }
}

// MARK: - Icons

extension Constants {
  enum Icons {
    static let `default`: String = "questionmark.circle"
    static let logo: String = "logo_icon"
    static let logoTitle: String = "logo_title_icon"
    static let sendText: String = "send_text_icon"
    static let attachImage: String = "attach_image_icon"
    static let messageSent: String = "message_sent_icon"
    static let messageRead: String = "message_read_icon"
    static let quit: String = "quit_icon"
  }
}
