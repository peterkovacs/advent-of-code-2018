import AdventOfCode
import Foundation
import FootlessParser

let parser = tuple <^> unsignedInteger <*> ((string(" players; last marble is worth ") *> unsignedInteger) <* string(" points"))
let (players, marble) = try! parse( parser, readLine(strippingNewline: true)! )

class Node {
  let value: Int
  var next, prev: Node!

  init() {
    value = 0
    next = self
    prev = self
  }

  init(value: Int, next: Node, prev: Node) {
    self.value = value
    self.next = next
    self.prev = prev
  }

  func index(offsetBy: Int) -> Node {
    switch offsetBy {
      case 0: return self
      case ..<0: return prev.index( offsetBy: offsetBy + 1 )
      case 1...: return next.index( offsetBy: offsetBy - 1 )
      default: fatalError()
    }
  }

  func add(next value: Int) -> Node {
    let node = Node(value: value, next: next, prev: self)
    next.prev = node
    next = node
    return node
  }

  func add(marble: Int) -> (Int, Node) {
    if marble % 23 == 0 {
      let index = self.index(offsetBy: -7)
      return ( marble + index.remove(), index.next )
    }

    let index = self.index(offsetBy: 1)
    let node = index.add(next: marble)
    return (0, node)
  }

  func remove() -> Int {
    next.prev = prev
    prev.next = next

    return value
  }

}

var current = Node()
var scores = [Int](repeating: 0, count: players)
var lowest = 1

for (lowest, player) in zip( 1...marble, cycle( scores.indices ) ) {
  let (score, next) = current.add(marble: lowest)
  scores[player] += score
  current = next
}

print("PART 1", scores.max() as Any)

current = Node()
scores = [Int](repeating: 0, count: players)
lowest = 1
for (lowest, player) in zip( 1...marble*100, cycle( scores.indices ) ) {
  let (score, next) = current.add(marble: lowest)
  scores[player] += score
  current = next
}

print("PART 2", scores.max() as Any)