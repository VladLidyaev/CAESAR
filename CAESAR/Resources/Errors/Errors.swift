// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation

// MARK: - LocalError

enum LocalError: LocalizedError {
  case noNetworkConnection
  case biometryIsNotAvailble
  case noAccessToSecureEnclave
  case unableToCreatePrivateKey
  case unableToGetConfig

  var errorDescription: String? {
    switch self {
    case .noNetworkConnection:
      return "No network connection."
    case .biometryIsNotAvailble:
      return "Biometry is not availble."
    case .noAccessToSecureEnclave:
      return "No access to Secure Enclave."
    case .unableToCreatePrivateKey:
      return "Unable to create private key."
    case .unableToGetConfig:
      return "Unable to get config."
    }
  }
}
