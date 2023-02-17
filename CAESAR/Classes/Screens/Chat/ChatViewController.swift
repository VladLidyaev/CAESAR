// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import UIKit

// MARK: - ChatViewController

class ChatViewController: CaesarViewController {
  // MARK: - Properties

  private var isTimerActive: Bool = false
  private var items: [Message] = [] {
    didSet {
      tableView.reloadData()
      tableView.scrollToBottom(animated: true)
    }
  }

  // MARK: - Subviews

  private lazy var quitButton = makeQuitButton()
  private lazy var quitButtonContainer = makeQuitButtonContainer()
  private lazy var tableView = makeTableView()
  private lazy var inputMessageView = makeInputMessageView()

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
    quitButtonContainer.pinToSuperviewSafeAreaEdge(.top, offset: LocalConstants.quitButtonTrailingOffset)
    quitButtonContainer.pinToSuperviewSafeAreaEdge(.trailing, offset: -LocalConstants.quitButtonTrailingOffset)

    // TableView
    tableView.pinToSuperviewEdge(.top)
    tableView.pin(.bottom, to: .top, of: inputMessageView)
    tableView.pinToSuperviewSafeAreaEdge(.trailing)
    tableView.pinToSuperviewSafeAreaEdge(.leading)
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
      onSendTap: { [weak self] text in
        self?.sendMessage(text: text)
      },
      updateInputMessageViewConstraintValue: { [weak self] value in
        self?.inputMessageViewHeightConstraint?.constant = value
        self?.animateLayout()
      }
    ).autoLayout()
    view.toolbar = toolbar
    return view
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
    manager?.deleteAllInfo()
  }

  // MARK: - Private Methods

  private func subscribeOnMessages() {
    manager?.subscribeOnMessages(onSuccess: { [weak self] items in
      self?.items = items
    })
  }

  private func sendMessage(text: String) {
    manager?.sendMessage(text: text)
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
        updateLayoutAction: { [weak self] in
          self?.view.layoutIfNeeded()
        }
      )
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

// MARK: - LocalConstants

private enum LocalConstants {
  static let cornerRadius: CGFloat = 15.0
  static let quitButtonSideLength: CGFloat = 28.0
  static let quitButtonVerticalOffset: CGFloat = 8.0
  static let quitButtonTrailingOffset: CGFloat = 12.0
  static let inputMessageViewBottomOffset: CGFloat = 34.0
  static let textViewInitialHeight: CGFloat = 60
  static let tableViewTopContentInset: CGFloat = quitButtonSideLength + quitButtonTrailingOffset + 3 * quitButtonVerticalOffset
}
