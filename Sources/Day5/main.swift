import Foundation
import AdventOfCode

extension Array where Element == UTF8.CodeUnit {
  func findReaction() -> Index? {
    let location = zip( self.enumerated(), self.dropFirst() ).first {
      let (a, b) = $0
      return a.element + 0x20 == b || a.element - 0x20 == b
    }

    return location.flatMap { index( startIndex, offsetBy: $0.0.offset ) }
  }

  func react() -> Array<Element> {
    var input = self
    while let index = input.findReaction() {
      input.removeSubrange( index...(input.index( index, offsetBy: 1) ) )
    }
    return input
  }
}

var input = Array(readLine(strippingNewline: true)!.utf8)
let part1 = input.react()
print( "PART 1", part1.count )

let alphabet = Array( "abcdefghijklmnopqrstuvwxyz".utf8 )
var result = [Int](repeating: 0, count: alphabet.count)
DispatchQueue.concurrentPerform( iterations: alphabet.count ) { i in
  let letter = alphabet[i]
  var working = input
  working.removeAll { $0 == letter || $0 == (letter - 0x20) }
  result[i] = working.react().count
}
print( "PART 2", result.min() as Any )