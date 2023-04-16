// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import UIKit

// MARK: - Message

struct Message {
  let data: MessageData
  let isUserAutor: Bool
  let timeLabelText: String
}

enum MessageData {
  case text(String)
  case image(UIImage)
}

struct MessageDataCodable: Codable {
  private enum MessageType: String, Codable {
    case image
    case text
  }
  private let type: MessageType
  private let value: String

  var data: MessageData? {
    switch type {
    case .image:
      guard let image = value.toImage() else { return nil }
      return .image(image)
    case .text:
      return .text(value)
    }
  }

  init?(_ data: MessageData) {
    switch data {
    case .text(let string):
      type = .text
      value = string
    case .image(let image):
      guard let string = image.toString() else { return nil }
      type = .image
      value = string
    }
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    type = try container.decode(MessageType.self, forKey: .type)
    value = try container.decode(String.self, forKey: .value)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(type, forKey: .type)
    try container.encode(value, forKey: .value)
  }

  private enum CodingKeys: String, CodingKey {
    case type
    case value
  }
}
