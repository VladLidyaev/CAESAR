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

  // MARK: - Error Handling

  private func handleError(_ error: Error? = nil) {
    guard let actualViewController = actualViewController else { return }
    actualViewController.showErrorAlert(message: error?.localizedDescription)
  }
}

// MARK: - LocalConstants

private enum LocalConstants {

}
