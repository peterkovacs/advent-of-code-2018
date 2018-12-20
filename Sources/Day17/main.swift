import Foundation
import FootlessParser
import CoreGraphics
import AdventOfCode

struct Clay {
  let x: Range<Int>
  let y: Range<Int>

  func minX() -> Int { return x.min()! }
  func maxX() -> Int { return x.max()! }
  func minY() -> Int { return y.min()! }
  func maxY() -> Int { return y.max()! }

  func draw(_ context: CGContext) -> CGContext {
    for (x, y) in iterate(self.x, and: self.y) {
      context[x: x, y: y] = .clay
    }
    return context
  }

}

func bounds(_ data: [Clay]) -> CGRect {
  let (minX, maxX, minY, maxY) = data.reduce(into: (Int.max, 0, Int.max, 0)) {
    $0.0 = min($0.0, $1.minX())
    $0.1 = max($0.1, $1.maxX())
    $0.2 = min($0.2, $1.minY())
    $0.3 = max($0.3, $1.maxY())
  }

  return CGRect(x: CGFloat(minX), y: CGFloat(minY), width: CGFloat(maxX + 1), height: CGFloat(maxY + 1) )
}

extension Pixel {
  var isClay: Bool {
    return r == 127 && g == 127 && b == 0
  }

  var canFlow: Bool {
    return isEmpty || isFlowing
  }

  var isEmpty: Bool {
    return a == 0
  }

  var isWater: Bool {
    return b == 255 && r == 0 && g == 0
  }

  var isFlowing: Bool {
    return a == 255 && isWater
  }

  var isResting: Bool {
    return a == 127 && isWater
  }

  var resting: Pixel {
    return Pixel(a: 127, r: r, g: g, b: b)
  }

  static let water = Pixel(a: 255, r: 0, g: 0, b: 255)
  static let clay = Pixel(a: 255, r: 127, g: 127, b: 0)
}

extension CGContext {
  func slide(color: Pixel, at p: Coordinate, direction: Coordinate.Direction) -> Coordinate? {
    let next = p[keyPath: direction]
    let down = p.down

    // We found an exit after sliding.
    if self[down].canFlow {
      self[p] = color
      return down
    } else if self[next].canFlow {
      // We can continue sliding in our current direction.
      self[p] = color

      if let next = slide(color: color, at: next, direction: direction) {
        // We found an exit further on, we're still flowing.
        return next
      } else {
        // We didn't find an exit, so we're now at rest.
        self[p] = color.resting
        return nil
      }
    } else {
      // We hit a dead end, we're now resting.
      self[p] = color.resting
      return nil
    }
  }

  // Set all the water in a current direction to be flowing.
  // This is used when we find an exit in one direction but not the other. The
  // entire level should be marked as flowing.
  func flowing(color: Pixel, at level: Coordinate) {
    var left = level
    while self[left].isWater {
      self[left] = color
      left = left.left
    }

    var right = level
    while self[right].isWater {
      self[right] = color
      right = right.right
    }
  }

  //  It's not enough to slide once, we need to slide until either both left and
  //  right find no exit, or they both find the bottom.
  func slide(color: Pixel, at p: Coordinate) -> Bool {
    var done = (left: false, right: false)
    while true {
      let left = done.left ? nil : slide(color: color, at: p, direction: \.left)
      let right = done.right ? nil : slide(color: color, at: p, direction: \.right)

      if left != nil || right != nil {
        flowing(color: color, at: p)
      }

      // Sliding left found an exit, recurse in that direction.
      if let left = left {
        done.left = drop(color: color, at: left)
      }

      // Sliding right found an exit, recurse in that direction.
      if let right = right {
        done.right = drop(color: color, at: right)
      }

      // If both sides finished we're done (and not resting).
      if done.left && done.right { return true }

      // If both sides had no exit, we're resting.
      if left == nil && right == nil {
        self[p] = color.resting
        return false
      }

      // a side is done if it found no exit.
      done.left  = left == nil
      done.right = right == nil
    }
  }

  // Recursively drop water into our clay reservoirs.
  func drop(color: Pixel, at p: Coordinate) -> Bool {
    let next = p.down

    self[p] = color

    guard next.isValid(x: width, y: height) else { return true }

    if self[next].isEmpty, drop(color: color, at: next) { return true } 

    // If we reach flowing water, then this branch is already done.
    else if self[next].isFlowing { return true }

    // We've reached something we can't drop onto, so slide left and right.
    return slide(color: color, at: p)
  }
}

let value = (curry({ Range($0...$1) }) <^> unsignedInteger <*> (string("..") *> unsignedInteger)) <|> ({ Range($0...$0) } <^> unsignedInteger)
let x = curry({ Clay(x: $0, y: $1) }) <^> (string("x=") *> value) <*> (string(", y=") *> value)
let y = curry({ Clay(x: $1, y: $0) }) <^> (string("y=") *> value) <*> (string(", x=") *> value)
let input = stdin.map { try! parse( x <|> y, $0 ) }

let rect = bounds(input)
let context = input.reduce(CGContext.create(size: rect.size)) { $1.draw($0) }
print(rect)

_ = context.drop(color: .water, at: Coordinate(x: 500, y: Int(rect.origin.y)))
print("PART 1", context.reduce(0) { $0 + ($1.isWater ? 1 : 0)})
print("PART 2", context.reduce(0) { $0 + ($1.isResting ? 1 : 0)})

context.save(to: URL(fileURLWithPath: "clay.png"))

