import CoreGraphics
import AdventOfCode
import FootlessParser
import Foundation

struct Point {
  let position: CGPoint
  let velocity: CGPoint

  static func *(lhs: Point, rhs: Int) -> CGPoint {
    return CGPoint( x: lhs.position.x + lhs.velocity.x * CGFloat(rhs), y: lhs.position.y + lhs.velocity.y * CGFloat(rhs) )
  }
}

extension Array where Element == Point {
  func area(at t: Int) -> CGFloat {
    let x = reduce(CGFloat.greatestFiniteMagnitude) { Swift.min( $0, ($1 * t).x ) }
    let y = reduce(CGFloat.greatestFiniteMagnitude) { Swift.min( $0, ($1 * t).y ) }
    let h = reduce(CGFloat.leastNormalMagnitude) { Swift.max( $0, ($1 * t).y ) } - y
    let w = reduce(CGFloat.leastNormalMagnitude) { Swift.max( $0, ($1 * t).x ) } - x
  
    return w * h
  }

  func description(at t: Int) -> String {
    let minX = reduce(Int.max) { Swift.min( $0, Int(($1 * t).x) ) }
    let minY = reduce(Int.max) { Swift.min( $0, Int(($1 * t).y) ) }
    let maxX = reduce(Int.min) { Swift.max( $0, Int(($1 * t).x) ) }
    let maxY = reduce(Int.min) { Swift.max( $0, Int(($1 * t).y) ) }

    var result = ""
    for y in minY...maxY {
      for x in minX...maxX {
        if contains(where: { Int(($0 * t).x) == x && Int(($0 * t).y) == y } ) {
          result.append("#")
        } else {
          result.append(" ")
        }
      }
      result.append("\n")
    }
    return result
  }
}

func parse() -> [Point] {
  let point = curry(CGPoint.init(x:y:)) <^> ( char("<") *> optional(whitespace) *> integer ) <*> (string(", ") *> optional(whitespace) *> integer <* char(">"))
  let line = curry(Point.init(position:velocity:)) <^> (string("position=") *> point) <*> (string(" velocity=") *> point)
  return stdin.map { try! parse( line, $0 ) }
}

let points = parse()
let minimumArea = (0..<20000).map{ ($0, points.area(at: $0)) }.min { $0.1 < $1.1}!

print( "PART 1" )
print( points.description( at: minimumArea.0 ) )
print( "PART 2")
print( minimumArea.0 )

extension Point: CustomStringConvertible {
  var description: String {
    return "(\(position), \(velocity))"
  }
}