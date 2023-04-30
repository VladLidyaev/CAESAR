// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import UIKit

// MARK: - MessageCell

class MessageCell: UITableViewCell {
  // MARK: - Properties

  var onImageTap: ((UIImage) -> Void)?

  // MARK: - Subviews

  private lazy var containerView = makeContainerView()
  private lazy var contentContainerView = makeContentContainerView()
  private lazy var imageContainer = makeImageContainer()
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

  override public init(
    style: UITableViewCell.CellStyle,
    reuseIdentifier: String?
  ) {
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
    containerContextMenuInteraction: UIContextMenuInteraction
  ) {
    model.cell = self
    model.containerView = containerView
    containerView.addInteraction(containerContextMenuInteraction)

    textView.removeFromSuperview()
    imageContainer.removeFromSuperview()
    switch model.data {
    case .text(let text):
      textView.isHidden = false
      imageContainer.isHidden = true
      textView.text = text
      setupTextView()
    case .image(let image):
      imageContainer.isHidden = false
      textView.isHidden = true
      imageContainer.image = image
      setupImageContainer()
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
  }

  // MARK: - Setup Methods

  private func setupUI() {
    selectionStyle = .none
    contentView.clipsToBounds = false
    contentView.addSubview(containerView)
    contentView.addSubview(timeLabel)
    containerView.addSubview(contentContainerView)
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

    // ContentContainerView
    contentContainerView.pinToSuperviewEdge(.leading, offset: LocalConstants.contentContainerBorderWidth)
    contentContainerView.pinToSuperviewEdge(.top, offset: LocalConstants.contentContainerBorderWidth)
    contentContainerView.pinToSuperviewEdge(.trailing, offset: -LocalConstants.contentContainerBorderWidth)
    contentContainerView.pinToSuperviewEdge(.bottom, offset: -LocalConstants.contentContainerBorderWidth)

    // TimeLabel
    timeLabelLeadingConstraint = timeLabel.pin(.leading, to: .trailing, of: containerView, offset: LocalConstants.timeLabelHorizontalOffset)
    timeLabelTrailingConstraint = timeLabel.pin(.trailing, to: .leading, of: containerView, offset: -LocalConstants.timeLabelHorizontalOffset)
    timeLabel.pin(.bottom, to: .bottom, of: containerView)
  }

  private func setupTextView() {
    contentContainerView.addSubview(textView)
    textView.pinToSuperviewEdge(.top)
    textView.pinToSuperviewEdge(.trailing, offset: -LocalConstants.textViewHorizontalOffset)
    textView.pinToSuperviewEdge(.bottom)
    textView.pinToSuperviewEdge(.leading, offset: LocalConstants.textViewHorizontalOffset)
  }

  private func setupImageContainer() {
    contentContainerView.addSubview(imageContainer)
    imageContainer.setDimensionsRatio(.heightToWidth, to: .one)
    imageContainer.pinEdgesToSuperview()
  }

  // MARK: - Views Constructors

  private func makeContainerView() -> UIView {
    let view = UIView().autoLayout()
    view.clipsToBounds = true
    view.layer.cornerRadius = LocalConstants.containerCornerRadius
    return view
  }

  private func makeContentContainerView() -> UIView {
    let view = UIView().autoLayout()
    view.clipsToBounds = true
    view.layer.cornerRadius = LocalConstants.contentContainerViewCornerRadius
    return view
  }

  private func makeImageContainer() -> UIImageView {
    let imageView = UIImageView().autoLayout()
    imageView.contentMode = .scaleAspectFill
    imageView.isUserInteractionEnabled = true
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleImageTap))
    imageView.addGestureRecognizer(tapGestureRecognizer)
    return imageView
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
    label.font = LocalConstants.timeLabelFont
    label.numberOfLines = 1
    return label
  }

  // MARK: - Tap Handler

  @objc
  private func handleImageTap() {
    guard let image = imageContainer.image else { return }
    onImageTap?(image)
  }
}

// MARK: - LocalConstants

private enum LocalConstants {
  static let containerCornerRadius: CGFloat = 15.0
  static let verticalMinOffset: CGFloat = 1.0
  static let verticalMaxOffset: CGFloat = 3.0
  static let horizontalMinOffset: CGFloat = 12.0
  static let horizontalMaxOffset: CGFloat = 90.0
  static let textFont = UIFont.systemFont(ofSize: 18, weight: .light)
  static let timeLabelFont = UIFont.systemFont(ofSize: 10, weight: .thin)
  static let timeLabelHorizontalOffset: CGFloat = 8.0
  static let contentContainerBorderWidth: CGFloat = 2.0
  static let contentContainerViewCornerRadius: CGFloat = containerCornerRadius - contentContainerBorderWidth
  static let textViewHorizontalOffset: CGFloat = 4.0
}
