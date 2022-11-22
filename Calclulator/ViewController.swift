//
//  ViewController.swift
//  Calclulator
//
//  Created by Hyejeong Park on 2022/11/21.
//

import UIKit

final class ViewController: UIViewController {
  
  // MARK: Properties
  
  private lazy var calculator: Calculator = Calculator(stackCapacity: 5, maxNumberLength: 18)
  
  private var currentNumber: Double { Double(currentNumberLabel.text ?? "") ?? 0 }
  
  // MARK: Outlets
  
  @IBOutlet weak var currentNumberLabel: UILabel!
  
  @IBOutlet weak var zeroButton: UIButton!
  
  @IBOutlet weak var decimalPointButton: UIButton!
  
  @IBOutlet var frameLabels: [UILabel]!
  
  @IBOutlet var frameViews: [UIView]!
  
  // MARK: Actions Methods
  
  @IBAction func pressNumber(_ sender: UIButton) {
    updateCurrentNumber(with: .number(sender.tag))
  }
  
  @IBAction func pressDecimalPoint(_ sender: UIButton) {
    updateCurrentNumber(with: .decimalPoint)
  }
  
  @IBAction func pressOperator(_ sender: UIButton) {
    guard let buttonTitle = sender.titleLabel?.text,
          let op = ArithmeticOperator.parse(buttonTitle.trimmingCharacters(in: .whitespaces)) else { return }
    updateCalculatorStack()
    calculator.latestOperator = op
    clearInput()
  }
  
  @IBAction func pressResult(_ sender: Any) {
    updateCalculatorStack()
    calculator.latestOperator = nil
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
    #warning("자리수 제한을 위반하려할 때 핸들링")
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
  
  private func updateCalculatorStack() {
    let result = calculator.calcuate(with: currentNumber)
    #warning("스택 개수 제한을 위반하려할 때 핸들링")
    updateStackFrame(with: result)
  }
  
  private func updateStackFrame(with values: [Double]) {
    for index in 0 ..< frameLabels.count {
      if index < values.count {
        frameLabels[index].text = String(format: "%.15f", values[index]) // "\(operand)"
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
  
  private func clearInput() {
    currentNumberLabel.text = "0"
    updateNumberPad()
  }
  
  private func resetAll() {
    updateStackFrame(with: calculator.reset())
    clearInput()
  }
  
  override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    if event?.subtype == .motionShake { resetAll() }
  }
  
}
