import Foundation
import AdventOfCode
import FootlessParser

enum Node: Character {
  case ns = "-"
  case ew = "|"
  case room = "."
  case unknown = "?"
  case wall = "#"

  var isDoor: Bool {
    return self == .ns || self == .ew
  }
}
extension Node: CustomStringConvertible {
  var description: String {
    return String(rawValue);
  }
}
enum Input {
  case go(Coordinate.Direction, Node), push, peek, pop, start, end
}
let parser: Parser<Character,Input> = [
  "N" as Character: .go(\Coordinate.up, .ns),
  "S": .go(\Coordinate.down, .ns),
  "E": .go(\Coordinate.right, .ew),
  "W": .go(\Coordinate.left, .ew),
  "(": .push,
  ")": .pop,
  "|": .peek,
  "^": .start,
  "$": .end,
].parser

guard let line = readLine(strippingNewline: true) else { exit(1) }
guard let input = try? parse( oneOrMore(parser), line) else { exit(1) }

extension Grid where Element == Node {
  func explore(input: [Input], start: Coordinate) -> Grid {
    var result = self
    var position = start
    var stack = [position]

    result[position] = .room

    for i in input {
      switch i {
        case .start, .end: break
        case .go(let d, let n):
          position = position[keyPath: d]
          result[position] = n
          position = position[keyPath: d]
          result[position] = .room
        case .push:
          stack.append(position)
        case .pop:
          position = stack.removeLast()
        case .peek:
          position = stack.last!
      }
    }

    for i in result.indices where result[i] == .unknown {
      result[i] = .wall
    }

    return result
  }

  // number of steps required to reach the furthest away room.
  func furthestRoom(start: Coordinate) -> Int {
    var queue = [(start, 0)]
    var visited = Set<Coordinate>()
    var maxDistance = 0

    while !queue.isEmpty {
      let (pos, d) = queue.removeFirst()

      visited.insert(pos)

      for i in pos.neighbors(limitedBy: count) where self[i].isDoor {
        let direction = pos.direction(to: i)
        let newPosition = i[keyPath: direction]

        if !visited.contains(newPosition) {
          queue.append((newPosition, d+1))
          maxDistance = Swift.max(d+1, maxDistance)
        }
      }
    }

    return maxDistance
  }

  func atLeastThousand(start: Coordinate) -> Int {
    var queue = [(start, 0)]
    var visited = Set<Coordinate>()
    var numberOfRooms = 0

    while !queue.isEmpty {
      let (pos, d) = queue.removeFirst()

      visited.insert(pos)

      for i in pos.neighbors(limitedBy: count) where self[i].isDoor {
        let direction = pos.direction(to: i)
        let newPosition = i[keyPath: direction]

        if !visited.contains(newPosition) {
          queue.append((newPosition, d+1))
          if d + 1 >= 1000 {
            numberOfRooms += 1
          }
        }
      }
    }

    return numberOfRooms
  }
}
var grid = Grid([Node](repeating: .unknown, count: 201 * 201), count: 201)!
var start = Coordinate(x: 103, y: 97)
grid = grid.explore(input: input, start: start)
print(grid)
print("PART 1", grid.furthestRoom(start: start))
print("PART 2", grid.atLeastThousand(start: start))