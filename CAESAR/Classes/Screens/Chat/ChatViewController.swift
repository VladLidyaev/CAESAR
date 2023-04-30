// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import UIKit

// MARK: - ChatViewController

class ChatViewController: CaesarViewController {
  // MARK: - Properties

  private var deletedItemIds = [String]()
  private var items: [Message] = [] {
    didSet {
      tableView.reloadData()
      tableView.scrollToBottom(animated: true)
      placeholderLabel.isHidden = !items.isEmpty
    }
  }

  // MARK: - Subviews

  private lazy var quitButton = makeQuitButton()
  private lazy var quitButtonContainer = makeQuitButtonContainer()
  private lazy var tableView = makeTableView()
  private lazy var inputMessageView = makeInputMessageView()
  private lazy var placeholderLabel = makePlaceholderLabel()
  private var imagePicker: ImagePicker?

  // MARK: - Constraints

  private var containerViewBottomConstraint: NSLayoutConstraint?
  private var inputMessageViewHeightConstraint: NSLayoutConstraint?

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    subscribeToKeyboardNotifications()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    subscribeOnMessages()
  }

  // MARK: - Setup UI

  private func setupUI() {
    view.backgroundColor = Colors.background
    quitButtonContainer.addSubview(quitButton)
    view.addSubview(quitButtonContainer)
    view.addSubview(tableView)
    tableView.addSubview(placeholderLabel)
    view.addSubview(inputMessageView)
    view.bringSubviewToFront(quitButtonContainer)
    setupConstraints()
  }

  private func setupConstraints() {
    // InputMessageView
    containerViewBottomConstraint = inputMessageView.pinToSuperviewEdge(
      .bottom,
      offset: -LocalConstants.inputMessageViewBottomOffset
    )
    inputMessageViewHeightConstraint = inputMessageView.setDimension(.height, to: LocalConstants.textViewInitialHeight)
    inputMessageView.pinToSuperviewSafeAreaEdge(.leading)
    inputMessageView.pinToSuperviewSafeAreaEdge(.trailing)

    // QuitButton
    quitButton.setDimensions(
      to: .init(
        width: LocalConstants.quitButtonSideLength,
        height: LocalConstants.quitButtonSideLength
      )
    )
    quitButton.pinToSuperviewEdge(.top, offset: LocalConstants.quitButtonVerticalOffset)
    quitButton.pinToSuperviewEdge(.trailing, offset: -LocalConstants.quitButtonVerticalOffset)
    quitButton.pinToSuperviewEdge(.bottom, offset: -LocalConstants.quitButtonVerticalOffset)
    quitButton.pinToSuperviewEdge(.leading, offset: LocalConstants.quitButtonVerticalOffset)

    // QuitButtonContainer
    quitButtonContainer.pinToSuperviewSafeAreaEdge(.top, offset: LocalConstants.quitButtonOffset)
    quitButtonContainer.pinToSuperviewSafeAreaEdge(.trailing, offset: -LocalConstants.quitButtonOffset)

    // TableView
    tableView.pinToSuperviewEdge(.top)
    tableView.pin(.bottom, to: .top, of: inputMessageView)
    tableView.pinToSuperviewSafeAreaEdge(.trailing)
    tableView.pinToSuperviewSafeAreaEdge(.leading)

    // PlaceholderLabel
    placeholderLabel.alignToSuperviewAxis(.vertical)
    placeholderLabel.alignToSuperviewAxis(.horizontal)
  }

  // MARK: - View Constructors

  private func makeQuitButton() -> UIView {
    let image = Icons.quit.withRenderingMode(.alwaysTemplate)
    let button = UIButton().autoLayout()
    button.setImage(image, for: .normal)
    button.tintColor = Colors.textAndIcons
    button.addTarget(self, action: #selector(didTapQuitButton(_:)), for: .touchUpInside)
    return button
  }

  private func makeQuitButtonContainer() -> UIView {
    let view = UIView().autoLayout()
    view.backgroundColor = Colors.background
    view.layer.cornerRadius = LocalConstants.cornerRadius
    return view
  }

  private func makeInputMessageView() -> InputMessageView {
    let view = InputMessageView(
      onSendButtonTap: { [weak self] text in
        self?.manager?.sendMessage(data: .text(text))
      },
      onAttachImageButtonTap: { [weak self] in
        self?.closeKeyboardIfNeeded()
        self?.presentImagePicker()
      },
      updateInputMessageViewConstraintValue: { [weak self] value in
        self?.inputMessageViewHeightConstraint?.constant = value
        self?.animateLayout()
      }
    ).autoLayout()
    view.toolbar = toolbar
    return view
  }

  private func makePlaceholderLabel() -> UILabel {
    let label = UILabel().autoLayout()
    label.clipsToBounds = true
    label.contentMode = .center
    label.numberOfLines = .zero
    label.font = LocalConstants.placeholderLabelFont
    label.textColor = Colors.textAndIcons.withAlphaComponent(LocalConstants.placeholderLabelTextAlpha)
    label.text = Strings.ChatViewController.placeholderTableText
    return label
  }

  private func makeTableView() -> UITableView {
    let tableView = UITableView().autoLayout()
    tableView.separatorStyle = .none
    tableView.backgroundColor = .clear
    tableView.delegate = self
    tableView.dataSource = self
    tableView.rowHeight = UITableView.automaticDimension
    let topInset = view.safeAreaInsets.top + LocalConstants.tableViewTopContentInset
    tableView.contentInset = UIEdgeInsets(
      top: topInset,
      left: .zero,
      bottom: .zero,
      right: .zero
    )
    tableView.register(
      MessageCell.self,
      forCellReuseIdentifier: String(describing: MessageCell.self)
    )
    return tableView
  }

  @objc
  private func didTapQuitButton(_: Any?) {
    manager?.deleteAllInfo(withChatEndedNotification: true)
  }

  // MARK: - Private Methods

  private func subscribeOnMessages() {
    manager?.subscribeOnMessages(onSuccess: { [weak self] items in
      self?.setItems(items)
    })
  }

  private func setItems(_ newItems: [Message]? = nil) {
    items = (newItems ?? items).filter { deletedItemIds.contains($0.id) == false }
  }

  private func closeKeyboardIfNeeded() {
    view.resignFirstResponder()
  }

  private func presentImagePicker() {
    imagePicker = ImagePicker()
    showImagePickerAlert(
      showImagePicker: { [weak self] sourceType in
        guard let self else { return }
        self.imagePicker?.present(
          from: self,
          sourceType: sourceType,
          completionHandler: { [weak self] image in
            guard let image else { return }
            self?.manager?.sendMessage(data: .image(image))
          }
        )
      }
    )
  }

  // MARK: - Layout Animation

  private func animateLayout(
    duration: TimeInterval = Constants.Animation.default,
    completion: (() -> Void)? = nil
  ) {
    UIView.animate(
      withDuration: duration,
      delay: .zero,
      options: [],
      animations: { [weak self] in
        self?.view.layoutIfNeeded()
      }, completion: { _ in
        completion?()
      }
    )
  }

  // MARK: - Helpers

  private func isUserItemAutor(at index: Int) -> Bool {
    guard index >= .zero, index < items.count else { return false }
    return items[index].isUserAutor
  }

  // MARK: - FullScreenImageView

  private func showFullScreenImageView(for image: UIImage) {
    let fullScreenImageVC = FullScreenImageViewController()
    fullScreenImageVC.image = image
    fullScreenImageVC.modalPresentationStyle = .overFullScreen
    fullScreenImageVC.modalTransitionStyle = .crossDissolve
    present(fullScreenImageVC, animated: true, completion: nil)
  }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    items.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let messageCell = tableView.dequeueReusableCell(
      withIdentifier: String(describing: MessageCell.self),
      for: indexPath
    ) as? MessageCell

    if let cell = messageCell {
      cell.configure(
        with: items[indexPath.row],
        isUserPreviousItemAutor: isUserItemAutor(at: indexPath.row - 1),
        isUserNextItemAutor: isUserItemAutor(at: indexPath.row + 1),
        containerContextMenuInteraction: UIContextMenuInteraction(delegate: self)
      )
      cell.onImageTap = { [weak self] image in self?.showFullScreenImageView(for: image) }
      return cell
    } else {
      return UITableViewCell()
    }
  }
}

// MARK: - Keyboard handling

extension ChatViewController {
  private func subscribeToKeyboardNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShow),
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillHide),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
  }

  @objc
  private func keyboardWillShow(notification: NSNotification) {
    guard
      let userInfo = notification.userInfo,
      let keyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
      let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
    else {
      return
    }

    let keyboardFrame = view.convert(keyboardFrameValue.cgRectValue, from: nil)
    containerViewBottomConstraint?.constant = -keyboardFrame.height
    animateLayout(duration: duration)
  }

  @objc
  private func keyboardWillHide(notification: NSNotification) {
    guard
      let userInfo = notification.userInfo,
      let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
    else {
      return
    }

    containerViewBottomConstraint?.constant = -LocalConstants.inputMessageViewBottomOffset
    animateLayout(duration: duration)
  }
}

extension ChatViewController: UIContextMenuInteractionDelegate {
  func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
    guard
      let model = items.filter({ $0.containerView === interaction.view }).first,
      let cell = model.cell
    else { return nil }
    tableView.bringSubviewToFront(cell)
    return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
      var actions = [UIAction]()

      // Copy
      actions.append(
        UIAction(
          title: Strings.MessageMenuContext.copy,
          image: Icons.copy.withTintColor(Colors.textAndIcons)
        ) { _ in
          switch model.data {
          case .text(let text):
            UIPasteboard.general.string = text
          case .image(let image):
            UIPasteboard.general.image = image
          }
        }
      )

      // Delete for me
      actions.append(
        UIAction(
          title: Strings.MessageMenuContext.deleteForMe,
          image: Icons.trash.withTintColor(Colors.destructive),
          attributes: .destructive
        ) { [weak self] _ in
          self?.deletedItemIds.append(model.id)
          self?.setItems()
        }
      )

      // Delete for everyone
      if model.isUserAutor {
        actions.append(
          UIAction(
            title: Strings.MessageMenuContext.deleteForEvereone,
            image: Icons.trash.withTintColor(Colors.destructive),
            attributes: .destructive
          ) { [weak self] _ in
            self?.manager?.deleteMessage(with: model.id)
          }
        )
      }

      return UIMenu(title: .empty, children: actions)
    }
  }
}

// MARK: - LocalConstants

private enum LocalConstants {
  static let timeLabelUpdateInterval: TimeInterval = 1.0
  static let cornerRadius: CGFloat = 13.0
  static let quitButtonSideLength: CGFloat = 28.0
  static let quitButtonVerticalOffset: CGFloat = 8.0
  static let quitButtonOffset: CGFloat = 12.0
  static let inputMessageViewBottomOffset: CGFloat = 34.0
  static let textViewInitialHeight: CGFloat = 60
  static let tableViewTopContentInset: CGFloat = quitButtonSideLength + quitButtonOffset + 3 * quitButtonVerticalOffset
  static let placeholderLabelTextAlpha: CGFloat = 0.5
  static let placeholderLabelFont: UIFont = UIFont.systemFont(ofSize: 20.0, weight: .regular)
}
