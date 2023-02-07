// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation

// MARK: - Constants

enum Constants {}

// MARK: - Animation

extension Constants {
  enum Animation {
    static let `default`: TimeInterval = 0.3
    static let extended: TimeInterval = `default` * 2
    static let accelerated: TimeInterval = `default` / 2
    static let blinking: TimeInterval = 2.0
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
  }
}
