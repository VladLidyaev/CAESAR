// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import UIKit

// MARK: - Icons

enum Icons {
  static let logo = IconAsset(name: Constants.Icons.logo).icon
  static let send = IconAsset(name: Constants.Icons.send).icon
  static let logoTitle = IconAsset(name: Constants.Icons.logoTitle).icon
}

// MARK: - IconAsset

struct IconAsset {
  fileprivate(set) var name: String
  
  var icon: UIImage {
    guard let image = UIImage(named: name) else {
      if let image = UIImage(systemName: Constants.Icons.default) {
        return image
      } else{
        fatalError("Unable to load image asset named \(name).")
      }
    }
    return image
  }
}
