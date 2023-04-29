// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import UIKit

// MARK: - MessageCell

class MessageCell: UITableViewCell {
  // MARK: - Subviews

  private lazy var containerView = makeContainerView()
  private lazy var textView = makeTextView()
  private lazy var timeLabel = makeTimeLabel()

  // MARK: - Constraints

  private var topConstraint: NSLayoutConstraint?
  private var trailingStrongConstraint: NSLayoutConstraint?
  private var trailingWeakConstraint: NSLayoutConstraint?
  private var bottomConstraint: NSLayoutConstraint?
  private var leadingStrongConstraint: NSLayoutConstraint?
  private var leadingWeakConstraint: NSLayoutConstraint?
  private var timeLabelLeadingConstraint: NSLayoutConstraint?
  private var timeLabelTrailingConstraint: NSLayoutConstraint?

  // MARK: - Initalization

  override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupUI()
  }

  func configure(
    with model: Message,
    isUserPreviousItemAutor: Bool,
    isUserNextItemAutor: Bool,
    updateLayoutAction: @escaping () -> Void
  ) {
    if case let .text(text) = model.data {
      textView.text = text
    } else {
      textView.text = .empty
    }

    timeLabel.text = TimeDeltaCalculator.calculateTimeDelta(creationDate: model.timestamp)

    topConstraint?.constant = isUserPreviousItemAutor == model.isUserAutor ? LocalConstants.verticalMinOffset : LocalConstants.verticalMaxOffset
    bottomConstraint?.constant = isUserNextItemAutor == model.isUserAutor ? -LocalConstants.verticalMinOffset : -LocalConstants.verticalMaxOffset

    if model.isUserAutor {
      containerView.backgroundColor = Colors.accent

      timeLabelLeadingConstraint?.isActive = false
      timeLabelTrailingConstraint?.isActive = true

      leadingStrongConstraint?.isActive = false
      trailingWeakConstraint?.isActive = false

      leadingWeakConstraint?.isActive = true
      leadingWeakConstraint?.constant = LocalConstants.horizontalMaxOffset

      trailingStrongConstraint?.isActive = true
      trailingStrongConstraint?.constant = -LocalConstants.horizontalMinOffset
    } else {
      containerView.backgroundColor = Colors.backgroundGray

      timeLabelTrailingConstraint?.isActive = false
      timeLabelLeadingConstraint?.isActive = true

      leadingWeakConstraint?.isActive = false
      trailingStrongConstraint?.isActive = false

      leadingStrongConstraint?.isActive = true
      leadingStrongConstraint?.constant = LocalConstants.horizontalMinOffset

      trailingWeakConstraint?.isActive = true
      trailingWeakConstraint?.constant = -LocalConstants.horizontalMaxOffset
    }
    updateLayoutAction()
  }

  // MARK: - Setup Methods

  private func setupUI() {
    selectionStyle = .none
    contentView.clipsToBounds = true

    contentView.addSubview(containerView)
    containerView.addSubview(textView)
    contentView.addSubview(timeLabel)
    setupContraints()
  }

  private func setupContraints() {
    // ContainerView
    topConstraint = containerView.pinToSuperviewEdge(.top)
    trailingStrongConstraint = containerView.pinToSuperviewEdge(.trailing)
    trailingWeakConstraint = containerView.pin(.trailing, lessThanOrEqualTo: .trailing, of: contentView)
    bottomConstraint = containerView.pinToSuperviewEdge(.bottom)
    leadingStrongConstraint = containerView.pinToSuperviewEdge(.leading)
    leadingWeakConstraint = containerView.pin(.leading, greaterThanOrEqualTo: .leading, of: contentView)

    trailingWeakConstraint?.isActive = false
    leadingWeakConstraint?.isActive = false

    // TextView
    textView.pinToSuperviewEdge(.top)
    textView.pinToSuperviewEdge(.trailing, offset: -LocalConstants.textViewHorizontalOffset)
    textView.pinToSuperviewEdge(.bottom)
    textView.pinToSuperviewEdge(.leading, offset: LocalConstants.textViewHorizontalOffset)

    // TimeLabel
    timeLabelLeadingConstraint = timeLabel.pin(.leading, to: .trailing, of: containerView, offset: LocalConstants.textViewHorizontalOffset)
    timeLabelTrailingConstraint = timeLabel.pin(.trailing, to: .leading, of: containerView, offset: -LocalConstants.textViewHorizontalOffset)
    timeLabel.pin(.bottom, to: .bottom, of: containerView)
  }

  // MARK: - Views Constructors

  private func makeContainerView() -> UIView {
    let view = UIView().autoLayout()
    view.layer.cornerRadius = LocalConstants.cornerRadius
    return view
  }

  private func makeTextView() -> UITextView {
    let textView = UITextView().autoLayout()
    textView.font = LocalConstants.textFont
    textView.textColor = Colors.textAndIcons
    textView.backgroundColor = .clear
    textView.isScrollEnabled = false
    textView.isEditable = false
    return textView
  }

  private func makeTimeLabel() -> UILabel {
    let label = UILabel().autoLayout()
    label.textColor = Colors.textAndIcons
    label.font = LocalConstants.timeLableFont
    label.numberOfLines = 1
    return label
  }
}

// MARK: - LocalConstants

private enum LocalConstants {
  static let cornerRadius: CGFloat = 15.0
  static let verticalMinOffset: CGFloat = 1.0
  static let verticalMaxOffset: CGFloat = 3.0
  static let horizontalMinOffset: CGFloat = 12.0
  static let horizontalMaxOffset: CGFloat = 84.0
  static let textFont = UIFont.systemFont(ofSize: 18, weight: .light)
  static let timeLableFont = UIFont.systemFont(ofSize: 10, weight: .thin)
  static let textViewHorizontalOffset: CGFloat = 8.0
}
