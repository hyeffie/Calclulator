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
  
  private var operands = Stack<Double>()
  
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
          let number = Int(buttonTitle.trimmingCharacters(in: .whitespaces)) else {
      return
    }
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
    print(#function)
    updateOperandStack()
    latestOperator = nil
    clearInput()
  }
  
  // MARK: LifeCycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print(#function)
    resetAll()
    
    frameLabels.enumerated().forEach {
      print($0, "번째", $1.text ?? "?")
    }
  }
  
  // MARK: Private Methods
  
  private func updateCurrentNumber(with input: CalculatorInput) {
    guard var current = currentNumberLabel.text else { return }
    guard current.count + 1 <= textCountLimit else {
      showNumberCountLimitAlert()
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
    if let op = latestOperator, let lhs = operands.pop()  {
      let rhs = currentNumber
      let result = op.operation(lhs, rhs)
      operands.push(result)
    } else {
      operands.push(currentNumber)
    }
    
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
  
  private func showNumberCountLimitAlert() {
    let alertController = UIAlertController(title: "알림",
                                  message: "소수점 포함 \(textCountLimit)자리까지 입력할 수 있어요",
                                  preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "알겠어요", style: .default))
    show(alertController, sender: nil)
  }
  
  private func clearInput() {
    currentNumberLabel.text = "0"
    updateNumberPad()
  }
  
  private func resetAll() {
    operands.resetAll()
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
  private var values: [Element] = []
  
  var count: Int { return values.count }
  
  var isEmpty: Bool { return values.isEmpty }
  
  mutating func push(_ element: Element) {
    values.append(element)
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
