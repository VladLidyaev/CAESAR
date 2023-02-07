// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation

// MARK: - ChatRequestDTO

struct MessageDTO {
  let id: String
  let user_id: String
  let data: Data
  let timestamp: Date

  init(
     id: String,
     user_id: String,
     data: Data,
     timestamp: Date = Date()
  ) {
    self.id = id
    self.user_id = user_id
    self.data = data
    self.timestamp = timestamp
  }

  init?(
    id: NSString?,
    user_id: NSString?,
    data: NSString?,
    timestamp: NSNumber?
  ) {
    guard
      let id = id as? String,
      let user_id = user_id as? String,
      let data_string = data as? String,
      let data = Data(base64Encoded: data_string),
      let timestamp = timestamp as? TimeInterval
    else { return nil }

    self.id = id
    self.user_id = user_id
    self.data = data
    self.timestamp = Date(timeIntervalSinceReferenceDate: timestamp)
  }
}

// MARK: - Keys

extension MessageDTO {
  enum Keys: String {
    case id
    case user_id
    case data
    case timestamp
  }
}
