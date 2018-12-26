import FootlessParser
import AdventOfCode

struct P4: Hashable {
  let x,y,z,t: Int

  static var parser: Parser<Character,P4> {
    return curry(P4.init) <^> (integer <* char(",")) <*> (integer <* char(",")) <*> (integer <* char(",")) <*> integer
  }

  static func - ( lhs: P4, rhs: P4 ) -> Int {
    let x = abs( lhs.x - rhs.x )
    let y = abs( lhs.y - rhs.y )
    let z = abs( lhs.z - rhs.z )
    let t = abs( lhs.t - rhs.t )
    return x + y + z + t
  }
}

let maximumDistance = 3
let points = stdin.map { try! parse( P4.parser, $0 ) }

let constellations = points.combinations(length: 2).filter { $0[0] - $0[1] <= maximumDistance }.reduce(into: [Set<P4>]()) { constellations, pair in 
  let (a, b) = (pair[0], pair[1])
  let matching = constellations.enumerated().filter({ $0.element.contains(where: { ($0 - a <= maximumDistance) || ($0 - b <= maximumDistance) }) }) 
  switch matching.count {
  case 2...:
      // we found a multiple constellations that we can merge with, merge constellations and insert their union.
      let combined = matching.reduce(Set(pair)) { $0.union($1.element) }
      for (offset, _) in matching.reversed() {
        constellations.remove(at: offset)
      }
      constellations.append(combined)
  case 1:
    // we found a single constellation that we can merge with, insert both points
    constellations[matching[0].offset].insert(pair[0])
    constellations[matching[0].offset].insert(pair[1])
  default:
    constellations.append( Set(pair) )
  }
}

print("PART 1", constellations.count + constellations.reduce(into: Set(points)) { $0.subtract($1) }.count )