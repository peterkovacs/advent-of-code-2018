import AdventOfCode
import FootlessParser
import Z3

extension Sequence {
  func count(where condition: (Element) throws -> Bool ) rethrows -> Int {
    return try reduce(into: 0) { if try condition($1) { $0 += 1 } }
  }
}

struct P4 {
  let x, y, z, r: Int

  static var parser: Parser<Character, P4> {
    return curry(P4.init) <^> (string("pos=<") *> integer) <*> (char(",") *> integer) <*> (char(",") *> integer <* char(">")) <*> (string(", r=") *> unsignedInteger)
  }

  static func - (lhs: P4, rhs: P4) -> Int {
    let x = abs(lhs.x - rhs.x)
    let y = abs(lhs.y - rhs.y)
    let z = abs(lhs.z - rhs.z)
    return x + y + z
  }
}

let points = stdin.compactMap { try? parse(P4.parser, $0) }
if let max = points.max(by: { $0.r < $1.r }) {
  print("PART 1", points.count(where: { max - $0 <= max.r }))
}

let (x, y, z) = (Z3.Int(named: "x"), Z3.Int(named: "y"), Z3.Int(named: "z"))
let inRanges = points.indices.map { Z3.Int(named: "in_range_\($0)") }
let sum = Z3.Int(named: "sum")
let distance = Z3.Int(named: "distance")
let o = Z3.optimize()!

for (i, point) in points.enumerated() {
    o.add(inRanges[i] == If( abs(x - Z3.Int32(point.x)) + abs(y - Z3.Int32(point.y)) + abs(z - Z3.Int32(point.z)) <= Z3.Int32(point.r), then: Z3.Int32(1), else: Z3.Int32(0)))
}

o.add( sum == inRanges.sum() )
o.add( distance == abs(x) + abs(y) + abs(z) )

let num = o.maximize(sum)
let dist = o.minimize(distance)

if o.check(), let lower = o.lower(dist), let upper = o.upper(dist) {
  print( "PART 2", lower, upper)
}