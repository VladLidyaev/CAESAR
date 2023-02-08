// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation

// MARK: - ChatDTO

struct ChatDTO {
  let id: String
  let chat_request_id: String
  let user_ids: [String]
  let message_ids: [String]
  let is_closed: Bool
  let timestamp: Date

  init(
    id: String = UUID().uuidString,
    chat_request_id: String,
    user_id: String,
    companion_id: String,
    message_ids: [String] = [],
    is_closed: Bool = false,
    timestamp: Date = Date()
  ) {
    self.id = id
    self.chat_request_id = chat_request_id
    self.user_ids = [user_id, companion_id]
    self.message_ids = message_ids
    self.is_closed = is_closed
    self.timestamp = timestamp
  }

  init?(from dictionary: Dictionary<String, Any>) {
    guard
      let id = dictionary[Keys.id.rawValue] as? String,
      let chat_request_id = dictionary[Keys.chat_request_id.rawValue] as? String,
      let user_ids = dictionary[Keys.user_ids.rawValue] as? [String],
      let is_closed = dictionary[Keys.is_closed.rawValue] as? Bool,
      let timestamp = dictionary[Keys.timestamp.rawValue] as? TimeInterval
    else { return nil }

    self.id = id
    self.chat_request_id = chat_request_id
    self.user_ids = user_ids
    self.message_ids = dictionary[Keys.message_ids.rawValue] as? [String] ?? [String]()
    self.is_closed = is_closed
    self.timestamp = Date(timeIntervalSinceReferenceDate: timestamp)
  }
}

// MARK: - Keys

extension ChatDTO {
  static let key: String = "chats"

  enum Keys: String {
    case id
    case chat_request_id
    case user_ids
    case message_ids
    case is_closed
    case timestamp
  }
}

// MARK: - asDictionary

extension ChatDTO {
  var asDictionary: Dictionary<String, Any> {
    return [
      Keys.id.rawValue: id,
      Keys.chat_request_id.rawValue: chat_request_id,
      Keys.user_ids.rawValue: user_ids,
      Keys.message_ids.rawValue: message_ids,
      Keys.is_closed.rawValue: is_closed,
      Keys.timestamp.rawValue: timestamp.timeIntervalSinceReferenceDate,
    ]
  }
}
