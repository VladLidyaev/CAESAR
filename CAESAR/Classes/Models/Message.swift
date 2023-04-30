// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import UIKit

// MARK: - Message

class Message {
  let id: String
  let data: MessageData
  let isUserAutor: Bool
  let timestamp: Date
  var cell: UITableViewCell?
  var containerView: UIView?

  init(
    id: String,
    data: MessageData,
    isUserAutor: Bool,
    timestamp: Date,
    cell: UITableViewCell? = nil,
    containerView: UIView? = nil
  ) {
    self.id = id
    self.data = data
    self.isUserAutor = isUserAutor
    self.timestamp = timestamp
    self.cell = cell
    self.containerView = containerView
  }
}

enum MessageData: Codable, Equatable {
  case text(String)
  case image(UIImage)

  private enum CodingKeys: CodingKey {
    case text
    case image
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if let text = try? container.decode(String.self, forKey: .text) {
      self = .text(text)
    } else if let image = try? container.decode(String.self, forKey: .image).toImage() {
      self = .image(image)
    } else {
      self = .text(.empty)
    }
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    switch self {
    case .text(let text):
      try container.encode(text, forKey: .text)
    case .image(let image):
      try? container.encode(image.toString(), forKey: .image)
    }
  }
}
