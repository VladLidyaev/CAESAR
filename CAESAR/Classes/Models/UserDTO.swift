// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation

// MARK: - UserDTO

struct UserDTO {
  let id: String
  let public_key: Data
  let display_name: String
  let chat_request_id: String?
  let chat_id: String?

  init(
     id: String,
     public_key: Data,
     display_name: String,
     chat_request_id: String? = nil,
     chat_id: String? = nil
  ) {
    self.id = id
    self.public_key = public_key
    self.display_name = display_name
    self.chat_request_id = chat_request_id
    self.chat_id = chat_id
  }

  init?(
    id: NSString?,
    public_key: NSString?,
    display_name: NSString?,
    chat_request_id: NSString?,
    chat_id: NSString?
  ) {
    guard
      let id = id as? String,
      let public_key_string = public_key as? String,
      let public_key = Data(base64Encoded: public_key_string),
      let display_name = display_name as? String
    else { return nil }

    self.id = id
    self.public_key = public_key
    self.display_name = display_name
    self.chat_request_id = chat_request_id as? String
    self.chat_id = chat_id as? String
  }
}

// MARK: - Keys

extension UserDTO {
  enum Keys: String {
    case id
    case public_key
    case display_name
    case chat_request_id
    case chat_id
  }
}
