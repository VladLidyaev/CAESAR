// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import UIKit

// MARK: - Colors

enum Colors {
  static let accent = ColorAsset(name: Constants.Colors.accent).color
  static let background = ColorAsset(name: Constants.Colors.background).color
  static let backgroundGray = ColorAsset(name: Constants.Colors.backgroundGray).color
  static let textAndIcons = ColorAsset(name: Constants.Colors.textAndIcons).color
  static let destructive = ColorAsset(name: Constants.Colors.destructive).color
}

// MARK: - ColorAsset

struct ColorAsset {
  fileprivate(set) var name: String

  var color: UIColor {
    guard let color = UIColor(named: name) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return color
  }
}
