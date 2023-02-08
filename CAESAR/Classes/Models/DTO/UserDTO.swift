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

  init?(from dictionary: Dictionary<String, Any>) {
    guard
      let id = dictionary[Keys.id.rawValue] as? String,
      let public_key_string = dictionary[Keys.public_key.rawValue] as? String,
      let public_key = Data(base64Encoded: public_key_string),
      let display_name = dictionary[Keys.display_name.rawValue] as? String
    else { return nil }

    self.id = id
    self.public_key = public_key
    self.display_name = display_name
    self.chat_request_id = dictionary[Keys.chat_request_id.rawValue] as? String
    self.chat_id = dictionary[Keys.chat_id.rawValue] as? String
  }
}

// MARK: - Keys

extension UserDTO {
  static let key: String = "users"

  enum Keys: String {
    case id
    case public_key
    case display_name
    case chat_request_id
    case chat_id
  }
}
