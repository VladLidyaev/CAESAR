// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import UIKit

// MARK: - MessageCell

class MessageCell: UITableViewCell {
  // MARK: - Subviews

  private lazy var messageLabel = makeMessageLabel()

  // MARK: - Initalization

  override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupUI()
  }

  func configure(with model: Message) {
    messageLabel.text = model.text
  }

  // MARK: - Setup Methods

  private func setupUI() {
    selectionStyle = .none
    contentView.clipsToBounds = true
    backgroundColor = .clear
    contentView.addSubview(messageLabel)
    setupContraints()
  }

  private func setupContraints() {
    // MessageLabel
    messageLabel.pinEdgesToSuperview()
  }

  // MARK: - Views Constructors

  private func makeMessageLabel() -> UILabel {
    let label = UILabel().autoLayout()
    label.textColor = Colors.textAndIcons
    label.lineBreakMode = .byClipping
    label.numberOfLines = .zero
    return label
  }
}

// MARK: - LocalConstants

private enum LocalConstants {

}
