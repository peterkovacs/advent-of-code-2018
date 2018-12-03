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
  static func claims(size: Int, fill input: [CGRect]) -> CGContext {
    let context = CGContext.square(size: size)
    context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5))
    input.forEach { context.fill( $0 ) }
    return context
  }

  var covered: Int {
    return (0..<height).reduce(0) { accum, y in (0..<width).reduce(accum) { accum, x in accum + (self[x: x, y: y].covered ? 1 : 0) }}
  }
}

let input = parse()
let size = 1000
let context = CGContext.claims(size: size, fill: input.map { $0.rect })
print("PART 1", context.covered)

let standalone = input.first { context[$0.rect].allSatisfy { $0.a == 128 } }
print("PART 2", standalone as Any)

// context.save(to: URL(fileURLWithPath: "image.png"))