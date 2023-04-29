// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation

// MARK: - UserDTO

struct UserDTO {
  let id: String
  let public_key: Data
  let chat_request_id: String?
  let chat_id: String?

  init(
    id: String,
    public_key: Data,
    chat_request_id: String? = nil,
    chat_id: String? = nil
  ) {
    self.id = id
    self.public_key = public_key
    self.chat_request_id = chat_request_id
    self.chat_id = chat_id
  }

  init?(from dictionary: Dictionary<String, Any>) {
    guard
      let id = dictionary[Keys.id.rawValue] as? String,
      let public_key_string = dictionary[Keys.public_key.rawValue] as? String,
      let public_key = Data(base64Encoded: public_key_string)
    else { return nil }

    self.id = id
    self.public_key = public_key
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
    case chat_request_id
    case chat_id
  }
}

// MARK: - asDictionary

extension UserDTO {
  var asDictionary: Dictionary<String, Any> {
    var dictionary = [
      Keys.id.rawValue: id,
      Keys.public_key.rawValue: public_key.base64EncodedString()
    ]
    dictionary[Keys.chat_request_id.rawValue] = chat_request_id
    dictionary[Keys.chat_id.rawValue] = chat_id
    return dictionary
  }
}
