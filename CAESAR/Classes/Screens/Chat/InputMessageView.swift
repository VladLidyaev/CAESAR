// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import UIKit

// MARK: - InputMessageView

class InputMessageView: UIView {
  // MARK: - Properties

  private let onSendButtonTap: (MessageData) -> Void
  private let updateInputMessageViewConstraintValue: (CGFloat) -> Void

  var toolbar = UIToolbar() {
    didSet {
      textView.inputAccessoryView = toolbar
    }
  }

  // MARK: - Computed variables

  private var data: MessageData? {
    var text: String? = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
    text = text?.containsOnlyWhitespacesAndNewlines == true ? nil : text
    return MessageData(
      text: text,
      image: nil
    )
  }

  // MARK: - Subviews

  private lazy var containerView = makeContainerView()
  private lazy var textView = makeTextView()
  private lazy var sendTextButton = makeSendTextButton()

  // MARK: - Initialization

  init(
    onSendButtonTap: @escaping (MessageData) -> Void,
    updateInputMessageViewConstraintValue: @escaping (CGFloat) -> Void
  ) {
    self.onSendButtonTap = onSendButtonTap
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
    containerView.addSubview(sendTextButton)
    setupConstraints()
  }

  private func setupConstraints() {
    // ContainerView
    containerView.pinToSuperviewEdge(.top, offset: LocalConstants.containerVerticalOffset)
    containerView.pinToSuperviewEdge(.trailing, offset: -LocalConstants.containerHorizontalOffset)
    containerView.pinToSuperviewEdge(.bottom, offset: -LocalConstants.containerVerticalOffset)
    containerView.pinToSuperviewEdge(.leading, offset: LocalConstants.containerHorizontalOffset)

    // TextView
    textView.pinToSuperviewEdge(.top, offset: LocalConstants.textViewVerticalOffset)
    textView.pinToSuperviewEdge(.trailing, offset: -LocalConstants.textViewtrailingOffset)
    textView.pinToSuperviewEdge(.bottom, offset: -LocalConstants.textViewVerticalOffset)
    textView.pinToSuperviewEdge(.leading, offset: LocalConstants.textViewLeadingOffset)

    // SendTextButton
    sendTextButton.setDimensions(
      to: .init(
        width: LocalConstants.sendTextButtonSideLength,
        height: LocalConstants.sendTextButtonSideLength
      )
    )
    sendTextButton.pinToSuperviewEdge(.trailing, offset: -LocalConstants.sendTextButtonOffset)
    sendTextButton.pinToSuperviewEdge(.bottom, offset: -LocalConstants.sendTextButtonOffset)
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

  private func makeSendTextButton() -> UIButton {
    let image = Icons.sendText.withRenderingMode(.alwaysTemplate)
    let button = UIButton().autoLayout()
    button.setImage(image, for: .normal)
    button.tintColor = Colors.textAndIcons
    button.isEnabled = false
    button.addTarget(self, action: #selector(didTapSendButton(_:)), for: .touchUpInside)
    return button
  }

  @objc
  private func didTapSendButton(_: Any?) {
    guard let data else { return }
    onSendButtonTap(data)
    textView.text = .empty
    updateState()
  }

  private func updateState() {
    let textViewContentHeight = textView.contentSize.height
    textView.showsVerticalScrollIndicator = textViewContentHeight >= LocalConstants.textViewMaxHeight
    sendTextButton.isEnabled = data != nil
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
  static let sendTextButtonDisabledStateAlpha: CGFloat = 0.5
  static let sendTextButtonOffset: CGFloat = 8.0
  static let sendTextButtonSideLength: CGFloat = 28.0
  static let textViewFont: UIFont = UIFont.systemFont(ofSize: 20.0, weight: .regular)
  static let textViewMinHeight: CGFloat = 40
  static let textViewMaxHeight: CGFloat = 136
  static let textViewVertialDiff: CGFloat = 2 * (sendTextButtonOffset + textViewVerticalOffset)
  static let textViewLeadingOffset: CGFloat = 16.0
  static let textViewtrailingOffset: CGFloat = 44.0
  static let textViewVerticalOffset: CGFloat = 2.0
}
