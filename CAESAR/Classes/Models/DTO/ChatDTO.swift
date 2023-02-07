// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation

// MARK: - ChatDTO

struct ChatDTO {
  let id: String
  let chat_request_id: String
  let user_ids: [String]
  let message_ids: [String]
  let timestamp: Date

  init(
     id: String,
     chat_request_id: String,
     user_id: String,
     message_ids: [String] = [],
     timestamp: Date = Date()
  ) {
    self.id = id
    self.chat_request_id = chat_request_id
    self.user_ids = [user_id]
    self.message_ids = message_ids
    self.timestamp = timestamp
  }

  init?(
    id: NSString?,
    chat_request_id: NSString?,
    user_ids: NSArray?,
    message_ids: NSArray?,
    timestamp: NSNumber?
  ) {
    guard
      let id = id as? String,
      let chat_request_id = chat_request_id as? String,
      let user_ids = user_ids as? [String],
      let message_ids = message_ids as? [String],
      let timestamp = timestamp as? TimeInterval
    else { return nil }

    self.id = id
    self.chat_request_id = chat_request_id
    self.user_ids = user_ids
    self.message_ids = message_ids
    self.timestamp = Date(timeIntervalSinceReferenceDate: timestamp)
  }
}

// MARK: - Keys

extension ChatDTO {
  enum Keys: String {
    case id
    case chat_request_id
    case user_ids
    case message_ids
    case timestamp
  }
}
