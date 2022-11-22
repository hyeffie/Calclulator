//
//  Stack.swift
//  Calclulator
//
//  Created by Hyejeong Park on 2022/11/22.
//

import Foundation

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
