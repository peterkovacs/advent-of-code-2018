import Foundation
import AdventOfCode
import FootlessParser

enum MobType {
  case elf, goblin
}

struct Mob {
  let type: MobType
  let power: Int
  var hitPoints: Int

  func hit(by mob: Mob) -> Node? {
    if hitPoints > mob.power {
      return .mob(Mob(type: type, power: power, hitPoints: hitPoints - mob.power))
    } else {
      return nil
    }
  }

  func isEnemy(_ them: Mob) -> Bool {
    switch (type, them.type) {
      case (.elf, .goblin), (.goblin, .elf): return true
      case (.goblin, .goblin), (.elf, .elf): return false
    }
  }
}

enum Node {
  case wall
  case open
  case mob(Mob)

  var isElf: Bool {
    if case .mob(let m) = self, m.type == .elf { return true } else { return false }
  }

  var isGoblin: Bool {
    if case .mob(let m) = self, m.type == .goblin { return true } else { return false }
  }
}

extension Node: CustomStringConvertible {
  public var description: String {
    switch self {
      case .wall: return "#"
      case .open: return "."
      case .mob(let m): 
        switch m.type {
          case .elf: return "E"
          case .goblin: return "G"
        }
    }
  }
}

struct State: CustomStringConvertible {
  var mobs: Set<Coordinate>
  var grid: Grid<Node>
  var round: Int

  init(grid: Grid<Node>) {
    self.round = 0
    self.grid = grid
    self.mobs = iterate( 0..<grid.count, and: 0..<grid.count).reduce(into: Set()) {
      switch grid[x: $1.0, y: $1.1 ] {
        case .mob(_): $0.insert(Coordinate(x: $1.0, y: $1.1))
        case .open, .wall: break
      }
    }
  }

  init(state: State, power: Int) {
    self.round = 0
    self.mobs = state.mobs
    self.grid = state.elves.reduce( into: state.grid ) {
      $0[$1] = .mob(Mob(type: .elf, power: power, hitPoints: 200))
    }
  }

  func next() -> State {
    var state = self
    var moved = Set<Coordinate>()
    for var mob in mobs.sorted() { 
      // Check that I'm still there (and haven't been killed)
      guard case .mob(let me) = state.grid[mob] else { continue }
      guard !moved.contains(mob) else { continue }

      // We immediately end as soon as there are no targets remaining. If
      // everyone hasn't gone, this doesn't count as a completed round.
      guard state.hasTarget(at: mob) else { return state }

      if let move = state.find(at: mob) {
        moved.insert(move)
        state.mobs.remove(mob)
        state.mobs.insert(move)
        (state.grid[move], state.grid[mob]) = (state.grid[mob], .open)
        mob = move
      } 

      if let (at,victim) = state.chooseVictim(at: mob) {
        if let node = victim.hit(by: me) {
          state.grid[at] = node
        } else {
          state.grid[at] = .open
          state.mobs.remove(at)
          moved.remove(at)
        }
      }
    }

    state.round += 1

    return state
  }

  func part1() -> State {
    var state = self
    while !state.isFinished {
      state = state.next()
    }
    return state
  }

  func part2() -> State {
    let elves = self.elves
    let power = (4...).first() { power in 
      var state = State(state: self, power: power)

      while !state.isFinished && elves.count == state.elves.count {
        state = state.next()
      }

      return elves.count == state.elves.count
    }

    return State(state: self, power: power!).part1()
  }

  func hasTarget(at coordinate: Coordinate) -> Bool {
    guard case .mob(let me) = grid[coordinate] else { return false }

    return mobs.contains { 
      if case .mob(let t) = grid[$0], me.isEnemy(t) { return true } else { return false }
    }
  }

  func chooseVictim(at coordinate: Coordinate) -> (Coordinate, Mob)? {
    guard case .mob(let me) = grid[coordinate] else { return nil }

    return coordinate.neighbors.compactMap { 
      guard case .mob(let j) = grid[$0], me.isEnemy(j) else { return nil }
      return ($0, j)
    }.sorted { (a: (Coordinate, Mob), b: (Coordinate, Mob)) in 
      a.1.hitPoints == b.1.hitPoints ? a.0 < b.0 : a.1.hitPoints < b.1.hitPoints 
    }.first 
  }

  func find(at start: Coordinate) -> Coordinate? {
    // Need to find all enemy nodes that are equal distance away, and
    // return the Coordinate that is one step closer to getting to the
    // tie-broken node.
    
    guard case .mob(let me) = grid[start] else { return nil }

    var queue = [(0, start)]
    var visited = Set<Coordinate>()
    var parents = [Coordinate:Coordinate]()
    var result = [Coordinate]()
    var best = Int.max

    func path(for destination: Coordinate) -> [Coordinate] {
      var result = [Coordinate]()
      var next = destination

      while next != start {
        result.append(next)
        guard let parent = parents[next] else { fatalError() }
        next = parent
      }

      return result
    }

    func next() -> Coordinate? {
      // Choose the target with the best read order.
      guard let target = result.min() else { return nil }
      return path( for: target ).last
    }

    while !queue.isEmpty {
      let (distance, i) = queue.removeFirst()

      for j in i.neighbors where !visited.contains(j) {
        visited.insert(j)
        parents[j] = i

        if case .mob(let them) = grid[j], me.isEnemy(them) {
          // We don't need to move at all
          guard distance > 0 else { return nil }

          // We've already found a better target
          guard distance <= best else { return next() }

          best = distance
          // *i* is the target square, not *j* (where the enemy is)
          result.append(i)
        } else if case .open = grid[j], distance < best {
          queue.append((distance + 1, j))
        }
      }
    }

    return next()
  }

  var isFinished: Bool {
    return !mobs.contains { grid[$0].isElf } || !mobs.contains { grid[$0].isGoblin }
  }

  var elves: [Coordinate] {
    return mobs.filter { grid[$0].isElf }
  }

  var hitPoints: Int {
    return mobs.reduce(into: 0) { 
      guard case .mob(let m) = grid[$1] else { return }
      $0 += m.hitPoints
    }
  }

  var description: String {
    // var result = "ROUND \(round)\n"
    var result = ""
    for y in 0..<grid.count {
      var mobs = ""
      for x in 0..<grid.count {
        let node = grid[x: x, y: y]
        result += node.description
        if case .mob(let m) = node {
          mobs += " \(node.description)(\(m.hitPoints))"
        }
      }
      if mobs.count > 0 {
        result += mobs
      }
      result += "\n"
    }
    return result
  }
}

let parser = oneOrMore( [
  "#": .wall,
  ".": .open,
  "E": .mob(Mob(type: .elf, power:3, hitPoints:200)), 
  "G": .mob(Mob(type: .goblin, power:3, hitPoints:200))
].parser as Parser<Character,Node> )
let grid = Grid<Node>( stdin.flatMap { try! parse( parser, $0 ) } )!

let part1 = State(grid: grid).part1()
print("PART 1", part1.round, part1.hitPoints, part1.hitPoints * part1.round )

let part2 = State(grid: grid).part2()
print("PART 2", part2.round, part2.hitPoints, part2.hitPoints * part2.round )