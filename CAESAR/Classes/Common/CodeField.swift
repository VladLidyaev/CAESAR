// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation
import UIKit

@IBDesignable
open class CodeField: UIStackView {

  public var doAfterCodeDidEnter: ((String) -> Void)?
  public var code: String {
    get {
      enteredCode.map { String($0) }.joined()
    }
    set {
      for (index, symbol) in newValue.enumerated() {
        textFields[index].value?.text = "\(symbol)"
      }
    }
  }

  public var toolbar = UIToolbar() {
    didSet {
      textFields.forEach { $0.value?.inputAccessoryView = toolbar }
    }
  }

  // MARK: Properties

  @IBInspectable
  private var blocks: Int = 0 {
    didSet {
      createBlocks()
    }
  }

  @IBInspectable
  private var elementsInBlock: Int = 0 {
    didSet {
      createBlocks()
    }
  }

  private var enteredCode: [Int] {
    var resultNumbers = [Int]()
    textFields.forEach { textField in
      if let text = textField.value?.text, let number = Int(text) {
        resultNumbers.append(number)
      }
    }
    return resultNumbers
  }

  class TFWrapper {
    weak var value: UITextField?
    init(_ tf: UITextField) {
      value = tf
    }
  }

  private var textFields: [TFWrapper] = []

  convenience public init(blocks: Int, elementsInBlock: Int) {

    guard blocks > 0, elementsInBlock > 0 else {
      fatalError("CodeField: Blocks and elements count must more than 0")
    }

    self.init(frame: .zero)

    self.blocks = blocks
    self.elementsInBlock = elementsInBlock

    createBlocks()
    configureMainStackView()
  }

  private func createBlocks() {
    guard blocks > 0, elementsInBlock > 0 else {
      return
    }

    removeArrangedViews()
    textFields.removeAll()

    (1...blocks).forEach { _ in
      let block = getBlockStackView()

      (1...elementsInBlock).forEach { elementIndex in
        let textField = getTextField()
        textFields.append(TFWrapper(textField))

        let stackView = UIStackView(arrangedSubviews: [textField, getBottomLine()])
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = 2

        block.addArrangedSubview(stackView)
      }
      self.addArrangedSubview(block)
    }
  }

  private func removeArrangedViews() {
    for view in arrangedSubviews {
      view.removeFromSuperview()
    }
  }

  private func configureMainStackView() {
    self.axis = .horizontal
    self.spacing = 20
    self.distribution = .fillEqually
  }

  private func getBlockStackView() -> UIStackView {
    let stackView = UIStackView()
    stackView.spacing = 5
    stackView.axis = self.axis
    stackView.distribution = .fillEqually
    return stackView
  }

  private func getTextField() -> UITextField {
    let textField = SWCodeTextField()
    textField.onDeleteBackward = {
      self.removeLastNumber()
      let lastFieldIndex = self.enteredCode.count
      self.textFields[lastFieldIndex].value?.becomeFirstResponder()
    }
    textField.keyboardType = .decimalPad
    textField.addAction(getActionFor(textField: textField), for: .editingChanged)
    textField.textAlignment = .center
    textField.font = .systemFont(ofSize: 30)
    textField.delegate = self
    return textField
  }

  private func getActionFor(textField: UITextField) -> UIAction {
    let action = UIAction { action in
      guard let text = textField.text, let _ = Int(text) else {
        return
      }
      let lastFieldIndex = self.enteredCode.count
      if lastFieldIndex < self.textFields.count && lastFieldIndex > 0  {
        self.textFields[lastFieldIndex].value?.becomeFirstResponder()
      } else {
        self.textFields.last?.value?.resignFirstResponder()
        self.doAfterCodeDidEnter?(self.code)
      }
    }
    return action
  }

  private func getBottomLine() -> UIView {
    let view = UIView()
    view.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 3))
    view.backgroundColor = Colors.textAndIcons
    view.layer.cornerRadius = 3
    return view
  }

  // MARK: Helpers

  private func removeLastNumber() {
    for textField in textFields.reversed() {
      if let text = textField.value?.text, text != "" {
        textField.value!.text =  ""
        return
      }
    }
  }

  private func activateCorrectTextField() {
    let lastFieldIndex = self.enteredCode.count
    if lastFieldIndex == textFields.count, let tf = self.textFields.first?.value {
      tf.becomeFirstResponder()
    } else if lastFieldIndex == 0, let tf = self.textFields.first?.value {
      tf.becomeFirstResponder()
    } else if let tf = self.textFields[lastFieldIndex].value {
      tf.becomeFirstResponder()
    } else {
      fatalError()
    }
  }

}

extension CodeField: UITextFieldDelegate {

  public func textFieldDidBeginEditing(_ textField: UITextField) {
    activateCorrectTextField()
  }

  public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if string.count > 1 {
      // TODO: Добавить обработку вставки текста
      return true
    } else {
      let maxLength = 1
      let currentString: NSString = (textField.text ?? "") as NSString
      let newString: NSString =
      currentString.replacingCharacters(in: range, with: string) as NSString
      return newString.length <= maxLength
    }
  }

}

fileprivate class SWCodeTextField: UITextField {
  var onDeleteBackward: (() -> Void)?
  override public func deleteBackward() {
    onDeleteBackward?()
    super.deleteBackward()
  }
}
