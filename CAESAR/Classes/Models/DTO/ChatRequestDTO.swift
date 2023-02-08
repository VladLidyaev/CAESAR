// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation

// MARK: - ChatRequestDTO

struct ChatRequestDTO {
  let id: String
  let user_id: String
  let timestamp: Date

  init(
     id: String,
     user_id: String,
     timestamp: Date = Date()
  ) {
    self.id = id
    self.user_id = user_id
    self.timestamp = timestamp
  }

  init?(from dictionary: Dictionary<String, Any>) {
    guard
      let id = dictionary[Keys.id.rawValue] as? String,
      let user_id = dictionary[Keys.user_id.rawValue] as? String,
      let timestamp = dictionary[Keys.timestamp.rawValue] as? TimeInterval
    else { return nil }

    self.id = id
    self.user_id = user_id
    self.timestamp = Date(timeIntervalSinceReferenceDate: timestamp)
  }
}

// MARK: - Keys

extension ChatRequestDTO {
  static let key: String = "chat_requests"

  enum Keys: String {
    case id
    case user_id
    case timestamp
  }
}
