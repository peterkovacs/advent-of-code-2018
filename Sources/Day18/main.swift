import AdventOfCode
import Foundation
import FootlessParser

enum Acre: CustomStringConvertible {
  case open, trees, lumberyard

  var description: String {
    switch self {
      case .open: return "."
      case .trees: return "|"
      case .lumberyard: return "#"
    }
  }
}

extension Array where Element == Acre {
  var trees: Int {
    return reduce(0) { $0 + (($1 == .trees) ? 1 : 0) }
  }

  var lumberyards: Int {
    return reduce(0) { $0 + (($1 == .lumberyard) ? 1 : 0) }
  }
}

extension Grid where Element == Acre {
  func next() -> Grid<Acre> {
    var grid = self
    for coordinate in indices {
      let neighbors = coordinate.neighbors8(limitedBy: count).map { self[$0] }

      switch self[coordinate] {
      case .open:
        if neighbors.trees > 2 {
          grid[coordinate] = .trees
        }
      case .trees:
        if neighbors.lumberyards > 2 {
          grid[coordinate] = .lumberyard
        }
      case .lumberyard:
         if neighbors.lumberyards < 1 || neighbors.trees < 1 {
           grid[coordinate] = .open
         }
      }
    }
    return grid
  }
}

let parser = oneOrMore( [
  ".": Acre.open,
  "|": Acre.trees,
  "#": Acre.lumberyard
].parser as Parser<Character,Acre> )

let input = Grid(try! parse( parser, stdin.joined(separator:"")))!
var part1 = input

for _ in 0..<10 { part1 = part1.next() }
print("PART 1", Array(part1).lumberyards * Array(part1).trees )

var part2 = input
// there's a cycle every 7000 iterations starting at 1000.
// conveniently 7000 divides into (1000000000 - 1000)
for _ in 1...1000 { part2 = part2.next() }
print("PART 2", Array(part2).lumberyards * Array(part2).trees )