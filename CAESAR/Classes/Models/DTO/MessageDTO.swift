// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation

// MARK: - ChatRequestDTO

struct MessageDTO {
  let id: String
  let user_id: String
  let data: Data
  let timestamp: Date

  init(
    id: String = UUID().uuidString,
     user_id: String,
     data: Data,
     timestamp: Date = Date()
  ) {
    self.id = id
    self.user_id = user_id
    self.data = data
    self.timestamp = timestamp
  }

  init?(from dictionary: Dictionary<String, Any>) {
    guard
      let id = dictionary[Keys.id.rawValue] as? String,
      let user_id = dictionary[Keys.user_id.rawValue] as? String,
      let data_string = dictionary[Keys.data.rawValue] as? String,
      let data = Data(base64Encoded: data_string),
      let timestamp = dictionary[Keys.timestamp.rawValue] as? TimeInterval
    else { return nil }

    self.id = id
    self.user_id = user_id
    self.data = data
    self.timestamp = Date(timeIntervalSinceReferenceDate: timestamp)
  }
}

// MARK: - Keys

extension MessageDTO {
  static let key: String = "messages"

  enum Keys: String {
    case id
    case user_id
    case data
    case timestamp
  }
}

// MARK: - asDictionary

extension MessageDTO {
  var asDictionary: Dictionary<String, Any> {
    return [
      Keys.id.rawValue: id,
      Keys.user_id.rawValue: user_id,
      Keys.data.rawValue: data.base64EncodedString(),
      Keys.timestamp.rawValue: timestamp.timeIntervalSinceReferenceDate,
    ]
  }
}
