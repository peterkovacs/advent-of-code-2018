import Foundation
import AdventOfCode
import FootlessParser

let depth = try! parse( string("depth: ") *> unsignedInteger, readLine(strippingNewline: true)!)
let target = try! parse( curry(Coordinate.init) <^> (string("target: ") *> unsignedInteger) <*> (char(",") *> unsignedInteger), readLine(strippingNewline: true)!)

enum Terrain: Int, CaseIterable {
  case rocky = 0, wet, narrow
}

extension Coordinate {
  var geologicIndex: Int {
    switch (x,y) {
      case (0, 0): return 0
      case (0, _): return y * 48271
      case (_, 0): return x * 16807
      case (target.x, target.y): return 0
      default: return left.erosionLevel * up.erosionLevel
    }
  }

  static var memoizedLevel: [Coordinate:Int] = [:]
  var erosionLevel: Int {
    if let level = Coordinate.memoizedLevel[self] {
      return level
    } else {
      let level = (geologicIndex + depth) % 20183
      Coordinate.memoizedLevel[self] = level
      return level
    }
  }

  var terrain: Terrain {
    return Terrain(rawValue: erosionLevel % 3)!
  }
}

let count = max( target.x, target.y )
let part1 = iterate( 0...target.x, and: 0...target.y ).reduce(0) { $0 + Coordinate(x: $1.0, y: $1.1).terrain.rawValue }
print("PART 1", part1 )

enum Tools: Int, CaseIterable {
  case torch = 1
  case climbingGear
  case neither

  func isCompatible(with terrain: Terrain) -> Bool {
    switch (self, terrain) {
      case (.torch, .rocky), (.climbingGear, .rocky): return true
      case (.neither, .rocky): return false

      case (.neither, .wet), (.climbingGear, .wet): return true
      case (.torch, .wet): return false

      case (.neither, .narrow), (.torch, .narrow): return true
      case (.climbingGear, .narrow): return false
    }
  }
}

struct Position: Hashable {
  let coordinate: Coordinate
  let tool: Tools

  var hashValue: Int {
    return coordinate.hashValue ^ tool.rawValue
  }
}

// BFS exploration from 0,0 to target
func explore(limit: Int, target: Coordinate) -> Int {
  let start = Position(coordinate: Coordinate(x: 0, y:0), tool: .torch)
  var queue = [(start, 0)]
  var visited = [start: 0]
  // At worst it's manhattan * (switch and move)
  let maxTime = (target.x + target.y) * 8
  var minTime = maxTime

  while !queue.isEmpty {
    let (position, time) = queue.removeFirst()
    // print(position, time)

    if position.coordinate == target, position.tool == .torch && minTime > time { 
      print(position, time)
      minTime = time
    }

    // Move or Switch to a mutually compatible tool & move.
    let positions = iterate( position.coordinate.neighbors(limitedBy: limit), and: Tools.allCases )
      .filter { (c,t) in t.isCompatible(with: position.coordinate.terrain) && t.isCompatible(with: c.terrain) }
      .map { (c,t) in 
        let p = Position(coordinate: c, tool: t)
        let t: Int = (t == position.tool) ? (time + 1) : (time + 8)

        return (p, t)
      }.filter { (p, t) in
        return t < minTime && t < visited[p, default: Int.max]
      }
    visited.merge(positions) { min( $0, $1 ) }

    let changeTools = Tools.allCases
      .filter { t in t != position.tool && t.isCompatible(with: position.coordinate.terrain) }
      .map { t in 
        let p = Position(coordinate: position.coordinate, tool: t)
        let t: Int = time + 7

        return (p, t)
      }.filter { (p, t) in
        return t < minTime && t < visited[p, default: Int.max]
      }
    visited.merge(changeTools) { min( $0, $1 ) }

    queue.append(contentsOf: positions)
    queue.append(contentsOf: changeTools)
    queue.sort { $0.1 < $1.1 }
  }

  return minTime
}

print("PART 2", explore(limit: count + 2, target: target) )