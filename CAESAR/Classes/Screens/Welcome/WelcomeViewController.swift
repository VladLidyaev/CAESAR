// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import UIKit

// MARK: - WelcomeViewController

class WelcomeViewController: CaesarViewController {
  // MARK: - Properties

  private var isTimerActive: Bool = false

  // MARK: - Subviews

  private lazy var stackView = makeStackView()
  private lazy var titleLabel = makeTitleLabel()
  private lazy var codeField = makeCodeField()
  private lazy var subtitleLabel = makeSubtitleLabel()
  private lazy var codeLabel = makeCodeLabel()
  private lazy var spacer = UIView().autoLayout()

  // MARK: - Constraints

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    subscribeOnCompanion()
  }

  // MARK: - Setup UI

  private func setupUI() {
    view.backgroundColor = Colors.background
    view.addSubview(stackView)
    setupConstraints()
  }

  private func setupConstraints() {
    // StackView
    stackView.pinToSuperviewSafeAreaEdge(.top, offset: LocalConstants.stackViewLargeOffset)
    stackView.pinToSuperviewSafeAreaEdge(.trailing, offset: -LocalConstants.stackViewOffset)
    stackView.pinToSuperviewSafeAreaEdge(.bottom, offset: -LocalConstants.stackViewOffset)
    stackView.pinToSuperviewSafeAreaEdge(.leading, offset: LocalConstants.stackViewOffset)

    titleLabel.setDimension(
      .height,
      equalTo: .height,
      of: stackView,
      multiplier: LocalConstants.titleLabelHeightMultiplier
    )

    codeField.setDimension(
      .height,
      equalTo: .height,
      of: stackView,
      multiplier: LocalConstants.codeFieldHeightMultiplier
    )

    subtitleLabel.setDimension(
      .height,
      equalTo: .height,
      of: stackView,
      multiplier: LocalConstants.subtitleLabelHeightMultiplier
    )

    codeLabel.setDimension(
      .height,
      equalTo: .height,
      of: stackView,
      multiplier: LocalConstants.codeLabelHeightMultiplier
    )
  }

  // MARK: - View Constructors

  private func makeStackView() -> UIStackView {
    let stackView = UIStackView(
      arrangedSubviews: [
        titleLabel,
        codeField,
        subtitleLabel,
        codeLabel,
        spacer
      ]
    ).autoLayout()
    stackView.setCustomSpacing(LocalConstants.stackViewLargeOffset, after: codeField)
    stackView.spacing = LocalConstants.stackViewSpacing
    stackView.axis = .vertical
    stackView.contentMode = .scaleAspectFit
    return stackView
  }

  private func makeTitleLabel() -> UILabel {
    let label = UILabel().autoLayout()
    label.numberOfLines = .zero
    label.textAlignment = .center
    label.text = Strings.WelcomeViewController.titleLabelText
    label.textColor = Colors.textAndIcons
    label.font = LocalConstants.titleFont
    return label
  }

  private func makeSubtitleLabel() -> UILabel {
    let label = UILabel().autoLayout()
    label.numberOfLines = .zero
    label.textAlignment = .center
    label.text = Strings.WelcomeViewController.subtitleLabelText
    label.textColor = Colors.textAndIcons
    label.font = LocalConstants.titleFont
    return label
  }

  private func makeCodeLabel() -> UILabel {
    let label = UILabel().autoLayout()
    label.numberOfLines = .zero
    label.textAlignment = .center
    label.text = manager?.chatRequestID?.withSpacings
    label.textColor = Colors.textAndIcons
    label.font = LocalConstants.codeFont
    return label
  }

  private func makeCodeField() -> CodeField {
    let codeField = CodeField(blocks: 1, elementsInBlock: Constants.Core.chatRequestIDLength)
    codeField.toolbar = toolbar
    codeField.doAfterCodeDidEnter = { [weak self] code in
      self?.waitingAlert(completion: { disMiss in
        self?.isTimerActive = true
        let disMissAction: () -> Void = {
          self?.isTimerActive = false
          self?.manager?.deleteSubscribeOnChat(chatRequestID: code)
          disMiss()
        }
        self?.manager?.config?.chatRequestTimer {
          if self?.isTimerActive == true { disMissAction() }
        }
        self?.manager?.requestChat(chatRequestID: code)
        self?.manager?.subscribeOnChat(chatRequestID: code, onSuccess: { chatDTO in
          disMissAction()
          self?.manager?.deleteSubscribeOnCompanion()
          self?.manager?.startChat(chatDTO: chatDTO)
        })
      })
    }
    return codeField
  }

  // MARK: - Private Methods

  private func subscribeOnCompanion() {
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      self?.manager?.subscribeOnCompanion(onSuccess: { userDTO in
        self?.showStartChatAlert(
          userName: userDTO.display_name,
          acceptAction: {
            self?.manager?.acceptChatRequest(
              with: userDTO.id,
              onSuccess: { chatDTO in
                self?.manager?.startChat(chatDTO: chatDTO)
              }
            )
          },
          declineAction: {
            self?.manager?.declineChatRequest()
          },
          completion: { disMiss in
            self?.isTimerActive = true
            self?.manager?.config?.chatRequestTimer {
              if self?.isTimerActive == true {
                self?.isTimerActive = false
                disMiss()
                self?.manager?.declineChatRequest()
              }
            }
          }
        )
      })
    }
  }
}

// MARK: - LocalConstants

private enum LocalConstants {
  static let stackViewSpacing: CGFloat = 8.0
  static let stackViewOffset: CGFloat = 32
  static let stackViewLargeOffset: CGFloat = 3 * stackViewOffset
  static let titleLabelHeightMultiplier: CGFloat = 1 / 6
  static let codeFieldHeightMultiplier: CGFloat = 1 / 8
  static let subtitleLabelHeightMultiplier: CGFloat = 1 / 8
  static let codeLabelHeightMultiplier: CGFloat = 1 / 8
  static let codeFont = UIFont.systemFont(ofSize: 30, weight: .regular)
  static let titleFont = UIFont.systemFont(ofSize: 30, weight: .heavy)
}
