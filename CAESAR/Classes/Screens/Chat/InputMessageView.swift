// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import UIKit

// MARK: - InputMessageView

class InputMessageView: UIView {
  // MARK: - Properties

  private let onSendButtonTap: (String) -> Void
  private let onAttachImageButtonTap: () -> Void
  private let updateInputMessageViewConstraintValue: (CGFloat) -> Void

  var toolbar = UIToolbar() {
    didSet {
      textView.inputAccessoryView = toolbar
    }
  }

  // MARK: - Subviews

  private lazy var containerView = makeContainerView()
  private lazy var textView = makeTextView()
  private lazy var sendButton = makeSendButton()
  private lazy var attachImageButton = makeAttachImageButton()
  private lazy var placeholderLabel = makePlaceholderLabel()

  // MARK: - Initialization

  init(
    onSendButtonTap: @escaping (String) -> Void,
    onAttachImageButtonTap: @escaping () -> Void,
    updateInputMessageViewConstraintValue: @escaping (CGFloat) -> Void
  ) {
    self.onSendButtonTap = onSendButtonTap
    self.onAttachImageButtonTap = onAttachImageButtonTap
    self.updateInputMessageViewConstraintValue = updateInputMessageViewConstraintValue
    super.init(frame: .zero)
    setupUI()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Setup UI

  private func setupUI() {
    addSubview(containerView)
    containerView.addSubview(textView)
    textView.addSubview(placeholderLabel)
    containerView.addSubview(attachImageButton)
    containerView.addSubview(sendButton)
    setupConstraints()
    setupKeyboardDismissRecognizer()
  }

  private func setupConstraints() {
    // ContainerView
    containerView.pinToSuperviewEdge(.top, offset: LocalConstants.containerVerticalOffset)
    containerView.pinToSuperviewEdge(.trailing, offset: -LocalConstants.containerHorizontalOffset)
    containerView.pinToSuperviewEdge(.bottom, offset: -LocalConstants.containerVerticalOffset)
    containerView.pinToSuperviewEdge(.leading, offset: LocalConstants.containerHorizontalOffset)

    // TextView
    textView.pinToSuperviewEdge(.top, offset: LocalConstants.textViewVerticalOffset)
    textView.pin(.trailing, to: .leading, of: attachImageButton, offset: -LocalConstants.buttonOffset)
    textView.pinToSuperviewEdge(.bottom, offset: -LocalConstants.textViewVerticalOffset)
    textView.pinToSuperviewEdge(.leading, offset: LocalConstants.textViewLeadingOffset)

    // PlaceholderLabel
    placeholderLabel.alignToAxis(.vertical, of: textView)
    placeholderLabel.pinToSuperviewEdge(.trailing)
    placeholderLabel.pinToSuperviewEdge(.leading, offset: LocalConstants.placeholderLabelLeadingOffset)

    // SendButton
    sendButton.setDimensions(
      to: .init(
        width: LocalConstants.buttonSideLength,
        height: LocalConstants.buttonSideLength
      )
    )
    sendButton.pinToSuperviewEdge(.trailing, offset: -LocalConstants.buttonOffset)
    sendButton.pinToSuperviewEdge(.bottom, offset: -LocalConstants.buttonOffset)

    // AttachImageButton
    attachImageButton.setDimensions(
      to: .init(
        width: LocalConstants.buttonSideLength,
        height: LocalConstants.buttonSideLength
      )
    )
    attachImageButton.pin(.trailing, to: .leading, of: sendButton, offset: -LocalConstants.buttonOffset)
    attachImageButton.pinToSuperviewEdge(.bottom, offset: -LocalConstants.buttonOffset)
  }

  private func setupKeyboardDismissRecognizer() {
    let swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeDown))
    swipeDownGestureRecognizer.direction = .down
    addGestureRecognizer(swipeDownGestureRecognizer)
  }

  // MARK: - View Constructors

  private func makeContainerView() -> UIView {
    let view = UIView().autoLayout()
    view.layer.cornerRadius = LocalConstants.containerHeight / 2
    view.layer.borderColor = Colors.textAndIcons.cgColor
    view.layer.borderWidth = LocalConstants.containerViewBorderWidth
    view.clipsToBounds = true
    return view
  }

  private func makeTextView() -> UITextView {
    let textView = UITextView().autoLayout()
    textView.backgroundColor = .clear
    textView.font = LocalConstants.textViewFont
    textView.clipsToBounds = true
    textView.textColor = Colors.textAndIcons
    textView.textContainer.lineBreakMode = .byClipping
    textView.autocapitalizationType = .sentences
    textView.spellCheckingType = .yes
    textView.showsVerticalScrollIndicator = false
    textView.delegate = self
    return textView
  }

  private func makeSendButton() -> UIButton {
    let image = Icons.send.withRenderingMode(.alwaysTemplate)
    let button = UIButton().autoLayout()
    button.setImage(image, for: .normal)
    button.tintColor = Colors.textAndIcons
    button.isEnabled = false
    button.addTarget(self, action: #selector(didTapSendButton(_:)), for: .touchUpInside)
    return button
  }

  private func makeAttachImageButton() -> UIButton {
    let image = Icons.attachImage.withRenderingMode(.alwaysTemplate)
    let button = UIButton().autoLayout()
    button.setImage(image, for: .normal)
    button.tintColor = Colors.textAndIcons
    button.addTarget(self, action: #selector(didTapAttachImageButton(_:)), for: .touchUpInside)
    return button
  }

  private func makePlaceholderLabel() -> UILabel {
    let label = UILabel().autoLayout()
    label.clipsToBounds = true
    label.contentMode = .center
    label.numberOfLines = .zero
    label.font = LocalConstants.textViewFont
    label.textColor = Colors.textAndIcons.withAlphaComponent(LocalConstants.placeholderLabelTextAlpha)
    label.text = Strings.ChatViewController.placeholderText
    return label
  }

  @objc
  private func didSwipeDown() {
    textView.resignFirstResponder()
  }

  @objc
  private func didTapSendButton(_: Any?) {
    onSendButtonTap(textView.text.trimmingCharacters(in: .whitespacesAndNewlines))
    textView.text = .empty
    updateState()
  }

  @objc
  private func didTapAttachImageButton(_: Any?) {
    onAttachImageButtonTap()
  }

  private func updateState() {
    let textViewContentHeight = textView.contentSize.height
    textView.showsVerticalScrollIndicator = textViewContentHeight >= LocalConstants.textViewMaxHeight
    sendButton.isEnabled = !textView.text.containsOnlyWhitespacesAndNewlines
    placeholderLabel.isHidden = !textView.text.isEmpty
    let textViewHeight = max(
      min(LocalConstants.textViewMaxHeight, textViewContentHeight),
      LocalConstants.textViewMinHeight
    )
    updateInputMessageViewConstraintValue(textViewHeight + LocalConstants.textViewVertialDiff)
  }
}

// MARK: - UITextViewDelegate

extension InputMessageView: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    updateState()
  }
}

// MARK: - LocalConstants

private enum LocalConstants {
  static let containerHorizontalOffset: CGFloat = 12.0
  static let containerVerticalOffset: CGFloat = 8.0
  static let containerHeight: CGFloat = 44.0
  static let containerViewBorderWidth: CGFloat = 2
  static let sendButtonDisabledStateAlpha: CGFloat = 0.5
  static let buttonOffset: CGFloat = 8.0
  static let buttonSideLength: CGFloat = 28.0
  static let textViewFont: UIFont = UIFont.systemFont(ofSize: 20.0, weight: .regular)
  static let textViewMinHeight: CGFloat = 40
  static let textViewMaxHeight: CGFloat = 136
  static let textViewVertialDiff: CGFloat = 2 * (buttonOffset + textViewVerticalOffset)
  static let textViewLeadingOffset: CGFloat = 16.0
  static let textViewVerticalOffset: CGFloat = 2.0
  static let placeholderLabelTextAlpha: CGFloat = 0.5
  static let placeholderLabelLeadingOffset: CGFloat = 4.5
}
