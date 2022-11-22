//
//  Calculator.swift
//  Calclulator
//
//  Created by Hyejeong Park on 2022/11/22.
//

import Foundation


struct Calculator {
  
  private var stack: Stack<Double>
  
  var stackedOperands: [Double] {
    var copy = self.stack
    var arr: [Double] = []
    while true {
      guard let item = copy.pop() else { break }
      arr.insert(item, at: 0)
    }
    return arr
  }
  
  var latestOperator: ArithmeticOperator? = nil
  
  let maxNumberLength: Int
  
  init(stackCapacity: Int, maxNumberLength: Int) {
    self.stack = Stack<Double>(capacity: stackCapacity)
    self.maxNumberLength = maxNumberLength
  }
  
  mutating func calcuate(with rhs: Double) -> [Double] {
    var new: Double
    if let op = latestOperator, let lhs = stack.pop() {
      new = op.operation(lhs, rhs)
    } else {
      new = rhs
    }
    stack.push(new)
//    guard stack.canPush else {
//          let message = "숫자는 \(5)개까지 보관할 수 있어요.\n최근 계산 내역은 저장되지 않아요."
//          showAlert(with: message)
//          return nil
//    }
    return stackedOperands
  }
  
  mutating func reset() -> [Double] {
    stack.resetAll()
    return stackedOperands
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
