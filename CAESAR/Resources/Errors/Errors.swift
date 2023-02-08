// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation

// MARK: - LocalError

enum LocalError: LocalizedError {
  case noNetworkConnection
  case biometryIsNotAvailble
  case noAccessToSecureEnclave
  case unableToGetConfig
  case unsupportedAppVersion

  var errorDescription: String? {
    switch self {
    case .noNetworkConnection:
      return "No network connection."
    case .biometryIsNotAvailble:
      return "Biometry is not availble."
    case .noAccessToSecureEnclave:
      return "No access to Secure Enclave."
    case .unableToGetConfig:
      return "Unable to get config."
    case .unsupportedAppVersion:
      return "You need to update the app to the latest available version."
    }
  }
}
