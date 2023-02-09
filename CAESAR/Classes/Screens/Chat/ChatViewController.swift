// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import UIKit

// MARK: - ChatViewController

class ChatViewController: CaesarViewController {
  // MARK: - Properties

  private var isTimerActive: Bool = false
  private var items: [Message] = [] {
    didSet {
      tableView.reloadData()
    }
  }

  // MARK: - Computed variables

  // MARK: - Subviews

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
    view.addSubview(tableView)
    view.addSubview(inputMessageView)
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

    // TableView
    tableView.pinEdgesToSuperview(excluding: .bottom)
    tableView.pin(.bottom, to: .top, of: inputMessageView)
  }

  // MARK: - View Constructors

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
    tableView.register(
      MessageCell.self,
      forCellReuseIdentifier: String(describing: MessageCell.self)
    )
    return tableView
  }

  // MARK: - Private Methods

  private func subscribeOnMessages() {
    
  }

  private func sendMessage(text: String) {

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
      cell.configure(with: items[indexPath.row])
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
  static let inputMessageViewBottomOffset: CGFloat = 34.0
  static let textViewInitialHeight: CGFloat = 60
}
