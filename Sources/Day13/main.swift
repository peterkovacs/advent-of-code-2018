import Foundation
import AdventOfCode
import FootlessParser
import Complex

enum Layout {
  case vertical
  case horizontal
  case northeast
  case northwest
  case intersection
}

enum Direction {
  case up, down, left, right
}

struct Ship {
  typealias Turn = (Ship) -> (Bool) -> Ship
  let direction: Direction
  let turn: Turn

  init(_ direction: Direction, turn: @escaping Turn = Ship.left) {
    self.direction = direction
    self.turn = turn
  }

  func left(_ intersection: Bool) -> Ship {
    let turn = intersection ? Ship.straight : self.turn
    switch direction {
      case .up:    return Ship(.left,  turn: turn)
      case .left:  return Ship(.down,  turn: turn)
      case .right: return Ship(.up,    turn: turn)
      case .down:  return Ship(.right, turn: turn)
    }
  }

  func straight(_ intersection: Bool) -> Ship {
    let turn = intersection ? Ship.right : self.turn
    switch direction {
      case .up:    return Ship(.up,    turn: turn)
      case .left:  return Ship(.left,  turn: turn)
      case .right: return Ship(.right, turn: turn)
      case .down:  return Ship(.down,  turn: turn)
    }
  }

  func right(_ intersection: Bool) -> Ship {
    let turn = intersection ? Ship.left : self.turn
    switch direction {
      case .up:    return Ship(.right, turn: turn)
      case .left:  return Ship(.up,    turn: turn)
      case .right: return Ship(.down,  turn: turn)
      case .down:  return Ship(.left,  turn: turn)
    }
  }

  func next(x: Int, y: Int) -> (Int, Int) {
    switch direction {
    case .up:    return (x,     y - 1)
    case .down:  return (x,     y + 1)
    case .left:  return (x - 1, y)
    case .right: return (x + 1, y)
    }
    
  }

  func next(on layout: Layout) -> Ship {
    switch (layout, direction) {
    case (.intersection, _):                         return turn(self)(true)
    case (.northeast,  .up),   (.northeast, .down):  return right(false)
    case (.northeast,  .left), (.northeast, .right): return left(false)
    case (.northwest,  .up),   (.northwest, .down):  return left(false)
    case (.northwest,  .left), (.northwest, .right): return right(false)
    case (.vertical, _),       (.horizontal, _):     return self
    }
  }
}

struct Node: CustomStringConvertible {
  let layout: Layout
  var ship: Ship?

  var description: String {
    switch (layout, ship?.direction) {
      case (_, .some(.up)): return "^"
      case (_, .some(.down)): return "v"
      case (_, .some(.left)): return "<"
      case (_, .some(.right)): return ">"
      case (.vertical, _): return "|"
      case (.horizontal, _): return "-"
      case (.northeast, _): return "/"
      case (.northwest, _): return "\\"
      case (.intersection, _): return "+"
    }
  }
}

struct Grid: CustomStringConvertible {
  var grid: [[Node?]]
  var ships: [(Int, Int)]

  init(grid: [[Node?]]) {
    self.grid = grid
    self.ships = iterate( 0..<grid[0].count, and: 0..<grid.count ).reduce(into: []) { 
      if grid[$1.1][$1.0]?.ship != nil {
        $0.append($1)
      }
    }
  }
  
  mutating func part1() -> (Int, Int)? {
    let original = grid
    var newShips = [(Int, Int)]()

    for (x, y) in ships {
      guard var node = original[y][x] else { fatalError() }
      guard let ship = node.ship  else { fatalError() }
      let (nx, ny) = ship.next(x: x, y: y)
      guard var next = grid[ny][nx] else { fatalError() }

      if next.ship != nil {
        return (nx, ny)
      }

      newShips.append((nx, ny))
      ( node.ship, next.ship ) = (nil, ship.next(on: next.layout))
      grid[y][x]               = node
      grid[ny][nx]             = next
    }

    ships = newShips.sorted { $0.1 == $1.1 ? $0.0 < $1.0 : $0.1 < $1.1 }

    return nil
  }

  mutating func part2() -> Bool {
    var original = grid
    var newShips: [(Int, Int)] = []

    for (x, y) in ships {
      guard var node = original[y][x] else { fatalError() }
      // It's possible the ship has been removed from an earlier collision
      guard let ship = node.ship      else { continue }

      let (nx, ny) = ship.next(x: x, y: y)
      guard var next = grid[ny][nx] else { fatalError() }

      if next.ship != nil {
        ( node.ship, next.ship ) = ( nil, nil )
        original[y][x]   = node
        original[ny][nx] = next
        grid[y][x]       = node
        grid[ny][nx]     = next
      } else {
        newShips.append((nx, ny))
        ( node.ship, next.ship ) = (nil, ship.next(on: next.layout))
        grid[y][x]               = node
        grid[ny][nx]             = next
      }
    }

    ships = newShips.sorted { $0.1 == $1.1 ? $0.0 < $1.0 : $0.1 < $1.1 }

    return ships.count < 2
  }

  var description: String {
    return grid.reduce(into: "") {
      $0.append( $1.reduce(into: "") { 
        if let node = $1 {
          $0 += node.description
        } else {
          $0 += " "
        }
      } )
      $0.append("\n")
    }
  }
}

func parse() -> Grid {
  typealias P = Parser<Character,Node?>
  let vertical: P      = { _ in Node(layout:.vertical,     ship:nil) }          <^> char("|")
  let horizontal: P    = { _ in Node(layout:.horizontal,   ship:nil) }          <^> char("-")
  let northeast: P     = { _ in Node(layout:.northeast,    ship:nil) }          <^> char("/")
  let northwest: P     = { _ in Node(layout:.northwest,    ship:nil) }          <^> char("\\")
  let intersection: P  = { _ in Node(layout:.intersection, ship:nil) }          <^> char("+")
  let nship: P         = { _ in Node(layout:.vertical,     ship:Ship(.up)) }    <^> char("^")
  let sship: P         = { _ in Node(layout:.vertical,     ship:Ship(.down)) }  <^> char("v")
  let eship: P         = { _ in Node(layout:.horizontal,   ship:Ship(.left)) }  <^> char("<")
  let wship: P         = { _ in Node(layout:.horizontal,   ship:Ship(.right)) } <^> char(">")
  let blank: P         = { _ in nil }                                           <^> char(" ")

  return Grid(grid: stdin.map { try! parse( oneOrMore( vertical <|> horizontal <|> northeast <|> northwest <|> intersection <|> nship <|> sship <|> eship <|> wship <|> blank ), $0 ) } )
}

let input = parse()

var grid = input
var part1: (Int, Int)? = nil
while part1 == nil {
  part1 = grid.part1()
} 
print("PART 1", part1 as Any)

grid = input
while !grid.part2() {}
print("PART 2", grid.ships)