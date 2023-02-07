// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation
import CryptoKit

// MARK: - CaesarManager

class CaesarManager {
  // MARK: - Properties

  let config: Config
  let userID: String
  let privateKey: P256.KeyAgreement.PrivateKey

  // MARK: - Computed variables

  // MARK: - Subviews

  // MARK: - Constraints

  // MARK: - Initialization
  
  init(
    config: Config,
    userID: String,
    privateKey: P256.KeyAgreement.PrivateKey
  ) {
    self.config = config
    self.userID = userID
    self.privateKey = privateKey
  }

  // MARK: - Public Methods

  // MARK: - Setup UI

  // MARK: - View Constructors

  // MARK: - Private Methods
}

// MARK: - LocalConstants

private enum LocalConstants {

}
