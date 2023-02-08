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

  private let userInfo: UserInfo
  private let databaseProvider: DatabaseProvider
  private var config: Config?
  private weak var actualViewController: UIViewController?

  // MARK: - Computed variables

  // MARK: - Constraints

  // MARK: - Initialization
  
  init(userInfo: UserInfo) {
    self.userInfo = userInfo
    self.databaseProvider = DatabaseProvider()
  }

  // MARK: - Public Methods

  func launch() {
    updateConfig()
  }

  // MARK: - Private Methods

  private func updateConfig() {
    databaseProvider.getConfig { [weak self] configDTO in
      let newConfig = Config(dto: configDTO)
      self?.config = newConfig
      self?.checkAppVersion(config: newConfig)
    } onError: { [weak self] error in
      self?.handleError(error)
    }
  }

  private func checkAppVersion(config: Config) {
    guard config.isVersionAvailbale(SystemProvider.bundleVersion) else {
      handleError(LocalError.unsupportedAppVersion)
      return
    }
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
