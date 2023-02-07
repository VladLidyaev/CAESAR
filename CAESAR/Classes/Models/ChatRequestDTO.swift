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

  init?(
    id: NSString?,
    user_id: NSString?,
    timestamp: NSNumber?
  ) {
    guard
      let id = id as? String,
      let user_id = user_id as? String,
      let timestamp = timestamp as? TimeInterval
    else { return nil }

    self.id = id
    self.user_id = user_id
    self.timestamp = Date(timeIntervalSinceReferenceDate: timestamp)
  }
}

// MARK: - Keys

extension ChatRequestDTO {
  enum Keys: String {
    case id
    case user_id
    case timestamp
  }
}
