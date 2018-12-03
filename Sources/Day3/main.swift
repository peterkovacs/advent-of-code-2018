import AdventOfCode
import FootlessParser
import CoreGraphics
import Foundation

struct Claim {
  let id: Int
  let rect: CGRect
}

func parse() -> [Claim] {
  let id = char("#") *> unsignedInteger
  let point = curry({ CGPoint(x: $0, y: $1) }) <^> ( unsignedInteger <* char(",")) <*> ( unsignedInteger <* char(":") )
  let size = curry({ CGSize(width: $0, height: $1) }) <^> ( unsignedInteger <* char("x")) <*> unsignedInteger
  let parser = curry({ Claim(id: $0, rect: CGRect(origin: $1, size: $2)) }) <^> id <*> (whitespaces *> char("@") *> whitespaces *> point) <*> (whitespaces *> size)
  return stdin.map { try! FootlessParser.parse(parser, $0) }
}

extension Pixel {
  var covered: Bool {
    return a > 128
  }
}

extension CGContext {
  static func covered(size: Int, fill input: [CGRect]) -> Int {
    let context = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue )!
    context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5))
    input.forEach { context.fill( $0 ) }
    return (0..<size).reduce(0) { accum, y in (0..<size).reduce(accum) { accum, x in accum + (context[x: x, y: y]!.covered ? 1 : 0) }}
  }
}

let input = parse()
let size = 1000
let covered = CGContext.covered(size: size, fill: input.map { $0.rect })
print("PART 1", covered)

let claim = input.enumerated().first { i in
  var working = input
  working.remove(at: i.offset)
  // Removing the rect didn't result in any coverage change
  // i doesn't intersect with any other rect in the working set
  return CGContext.covered(size: size, fill: working.map { $0.rect }) == covered && working.allSatisfy { !$0.rect.intersects(i.element.rect) }
}
print("PART 2", claim as Any)