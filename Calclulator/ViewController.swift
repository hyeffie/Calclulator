//
//  ViewController.swift
//  Calclulator
//
//  Created by Hyejeong Park on 2022/11/21.
//

import UIKit

final class ViewController: UIViewController {
  
  // MARK: Properties
  
  private let textCountLimit = 18
  
  private var operands = Stack<Double>(capacity: 5)
  
  private var currentNumber: Double { Double(currentNumberLabel.text ?? "") ?? 0 }
  
  private var latestOperator: ArithmeticOperator? = nil
  
  // MARK: Outlets
  
  @IBOutlet weak var currentNumberLabel: UILabel!
  
  @IBOutlet weak var zeroButton: UIButton!
  
  @IBOutlet weak var decimalPointButton: UIButton!
  
  @IBOutlet var frameLabels: [UILabel]!
  
  @IBOutlet var frameViews: [UIView]!
  
  // MARK: Actions Methods
  
  @IBAction func pressNumber(_ sender: UIButton) {
    guard let buttonTitle = sender.titleLabel?.text,
          let number = Int(buttonTitle.trimmingCharacters(in: .whitespaces)) else { return }
    updateCurrentNumber(with: CalculatorInput.number(number))
  }
  
  @IBAction func pressDecimalPoint(_ sender: UIButton) {
    updateCurrentNumber(with: CalculatorInput.decimalPoint)
  }
  
  @IBAction func pressOperator(_ sender: UIButton) {
    guard let buttonTitle = sender.titleLabel?.text,
          let op = ArithmeticOperator.parse(buttonTitle.trimmingCharacters(in: .whitespaces)) else { return }
    updateOperandStack()
    latestOperator = op
    clearInput()
  }
  
  @IBAction func pressResult(_ sender: Any) {
    updateOperandStack()
    latestOperator = nil
    clearInput()
  }
  
  // MARK: LifeCycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    resetAll()
  }
  
  // MARK: Private Methods
  
  private func updateCurrentNumber(with input: CalculatorInput) {
    guard var current = currentNumberLabel.text else { return }
    guard current.count + 1 <= textCountLimit else {
      let message = "소수점 포함 \(textCountLimit)자리까지 입력할 수 있어요."
      showAlert(with: message)
      return
    }
    switch input {
    case .number(let value):
      if current == "0" {
        if value == 0 { return }
        current = ""
      }
    case .decimalPoint:
      if current.contains(".") { return }
    }
    currentNumberLabel.text = current + input.output
    updateNumberPad()
  }
  
  private func updateOperandStack() {
    var new = Double()
    if let op = latestOperator, let lhs = operands.pop()  {
      let rhs = currentNumber
      new = op.operation(lhs, rhs)
    } else {
      new = currentNumber
    }
    guard operands.canPush else {
      let message = "숫자는 \(5)개까지 보관할 수 있어요.\n최근 계산 내역은 저장되지 않아요."
      showAlert(with: message)
      return
    }
    operands.push(new)
    updateStackFrame()
  }
  
  private func updateStackFrame() {
    var copy = operands
    var arr: [Double] = []
    while true {
      guard let item = copy.pop() else { break }
      arr.insert(item, at: 0)
    }
    for index in 0 ..< frameLabels.count {
      if index < arr.count {
        frameLabels[index].text = String(format: "%.15f", arr[index]) // "\(operand)"
        frameViews[index].layer.borderWidth = 3
        frameViews[index].layer.borderColor = UIColor.systemGray2.cgColor
      } else {
        frameLabels[index].text = "Stack \(index + 1)"
        frameViews[index].layer.borderWidth = 0
      }
    }
  }
  
  private func updateNumberPad() {
    guard let current = currentNumberLabel.text else { return }
    zeroButton.isEnabled = current != "0"
    decimalPointButton.isEnabled = !current.contains(".")
  }
  
  private func showAlert(with message: String) {
    let alertController = UIAlertController(title: "알림",
                                  message: message,
                                  preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "알겠어요", style: .default))
    show(alertController, sender: nil)
  }
  
  private func clearInput() {
    currentNumberLabel.text = "0"
    updateNumberPad()
  }
  
  override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    if event?.subtype == .motionShake {
      resetAll()
    }
  }
  
  private func resetAll() {
    operands.resetAll()
    updateStackFrame()
    clearInput()
  }
  
}

enum CalculatorInput {
  case number(Int)
  case decimalPoint
  
  var output: String {
    switch self {
    case .decimalPoint: return "."
    case .number(let value): return "\(value)"
    }
  }
}

enum ArithmeticOperator: Int {
  case add, subtract, multiply, divide
  
  var operation: (Double, Double) -> Double {
    switch self {
    case .add: return { $0 + $1 }
    case .subtract: return { $0 - $1 }
    case .multiply: return { $0 * $1 }
    case .divide: return { $0 / $1 }
    }
  }
  
  static func parse(_ symbol: String) -> Self? {
    switch symbol {
    case "+": return .add
    case "-": return .subtract
    case "*": return .multiply
    case "/": return .divide
    default: return nil
    }
  }
}

struct Stack<Element> {
  private var values: [Element]
  
  private let capacity: Int?
  
  var count: Int { return values.count }
  
  var isEmpty: Bool { return values.isEmpty }
  
  public var canPush: Bool {
    if let capacity = capacity { return count < capacity }
    return true
  }
  
  init(capacity: Int) {
    self.capacity = capacity
    self.values = []
  }
  
  mutating func push(_ element: Element) {
    if canPush { values.append(element) }
  }
  
  mutating func pop() -> Element? {
    values.popLast()
  }
  
  func peek() -> Element? {
    values.last
  }
  
  mutating func resetAll() {
    values.removeAll()
  }
}
