// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation

// MARK: - ChatRequestDTO

struct ChatRequestDTO {
  let id: String
  let user_id: String
  let companion_id: String?
  let chat_id: String?
  let timestamp: Date

  init(
     id: String,
     user_id: String,
     companion_id: String? = nil,
     chat_id: String? = nil,
     timestamp: Date = Date()
  ) {
    self.id = id
    self.user_id = user_id
    self.companion_id = companion_id
    self.chat_id = chat_id
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
    self.companion_id = dictionary[Keys.companion_id.rawValue] as? String
    self.chat_id = dictionary[Keys.chat_id.rawValue] as? String
    self.timestamp = Date(timeIntervalSinceReferenceDate: timestamp)
  }
}

// MARK: - Keys

extension ChatRequestDTO {
  static let key: String = "chat_requests"

  enum Keys: String {
    case id
    case user_id
    case companion_id
    case chat_id
    case timestamp
  }
}

// MARK: - asDictionary

extension ChatRequestDTO {
  var asDictionary: Dictionary<String, Any> {
    var dictionary: Dictionary<String, Any> = [
      Keys.id.rawValue: id,
      Keys.user_id.rawValue: user_id,
      Keys.timestamp.rawValue: timestamp.timeIntervalSinceReferenceDate,
    ]
    dictionary[Keys.companion_id.rawValue] = companion_id
    dictionary[Keys.chat_id.rawValue] = chat_id
    return dictionary
  }
}
