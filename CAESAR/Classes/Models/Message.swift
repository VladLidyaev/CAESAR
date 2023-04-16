// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import UIKit

// MARK: - Message

struct Message {
  let data: MessageData
  let isUserAutor: Bool
  let timestamp: Date
}

struct MessageData: Codable {
  let text: String?
  let image: UIImage?

  init?(
    text: String?,
    image: UIImage?
  ) {
    guard text != nil || image != nil else { return nil }
    self.text = text
    self.image = image
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    text = try? container.decode(String.self, forKey: .text)
    let imageDataString = try? container.decode(String.self, forKey: .image)
    image = imageDataString?.toImage()
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(text, forKey: .text)
    let imageDataString = image?.toString()
    try container.encode(imageDataString, forKey: .image)
  }

  private enum CodingKeys: String, CodingKey {
    case text
    case image
  }
}
