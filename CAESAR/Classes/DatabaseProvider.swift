// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation
import FirebaseDatabase

// MARK: - DatabaseProvider

class DatabaseProvider {
  // MARK: - Properties

  private var mainReference: DatabaseReference

  // MARK: - Computed variables

  // MARK: - Constraints

  // MARK: - Initialization

  init() {
    mainReference = Database.database().reference()
  }

  // MARK: - Public Methods

  func getConfig(
    onSuccess: @escaping (ConfigDTO) -> Void,
    onError: @escaping (Error?) -> Void
  ) {
    mainReference.child(ConfigDTO.key).getData { error, snapshot in
      guard let snapshot = snapshot else {
        onError(error)
        return
      }

      guard
        let dictionary = snapshot.value as? Dictionary<String, Any>,
        let configDTO = ConfigDTO(from: dictionary)
      else {
        onError(LocalError.unableToGetConfig)
        return
      }

      onSuccess(configDTO)
    }
  }

  // MARK: - View Constructors

  // MARK: - Private Methods
}

// MARK: - LocalConstants

private enum LocalConstants {

}
