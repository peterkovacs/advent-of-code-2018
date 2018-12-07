import AdventOfCode
import FootlessParser
import Foundation 

struct Graph: Sequence, IteratorProtocol {
  typealias Element = Character
  var graph: [Character: [Character]]
  var available: Set<Character>

  init(input: [(Character, Character)]) {
    let initial = Set(input.map {$0.0})
    graph = input.reduce(into: Dictionary(uniqueKeysWithValues: initial.map { ($0, []) })) {
      $0[$1.1, default: []].append($1.0)
    }
    available = Set<Character>( graph.reduce(into: []) { if $1.value.isEmpty { $0.append( $1.key ) } } )
  }

  mutating func remove(_ label: Character) {
    // Remove from graph
    graph[label] = nil

    // Remove from all dependencies
    graph = graph.mapValues() {
      var value = $0
      value.removeAll() { $0 == label }
      return value
    }

    // generate available set
    available = Set<Character>( graph.reduce(into: []) { if $1.value.isEmpty { $0.append( $1.key ) } } )
  }

  func peek() -> Character? {
    return available.min()
  }

  mutating func work() -> Character? {
    guard let value = peek() else { return nil }

    // Remove from graph and available, but not dependencies.
    graph[value] = nil
    available.remove(value)

    return value
  }

  var isEmpty: Bool {
    return graph.isEmpty
  }

  mutating func next() -> Character? {
    guard let value = peek() else { return nil }
    defer { remove(value) }
    return value
  }
}

struct Worker {
  var letter: Character
  var time: Int

  init(letter: Character) {
    self.letter = letter
    self.time = 60 + Int( letter.unicodeScalars.first!.value - 0x40 )
  }

  init?(letter: Character?) {
    guard let letter = letter else { return nil }
    self.init(letter: letter)
  }

  mutating func tick() -> Bool {
    time -= 1
    return time > 0
  }
}

func parse() -> [(Character, Character)] {
  let parser = tuple <^> (string("Step ") *> any()) <*> ((string( " must be finished before step ") *> any()) <* string(" can begin."))
  return stdin.map { try! parse( parser, $0 ) }
}

let input = parse()
let graph = Graph(input: input)
let part1 = String(graph)
print("PART 1", part1)

var part2 = graph
var workers = (0..<5).compactMap() { _ in Worker(letter: part2.work() ) }
var time = 0
while !part2.isEmpty || !workers.isEmpty {
  workers = workers.reduce(into: []) {
    var worker = $1
    if worker.tick() { 
      $0.append(worker)
    } else {
      part2.remove($1.letter)
    }
  }
  time += 1
  workers.append( contentsOf: (workers.count..<5).compactMap() { _ in Worker(letter: part2.work()) } )
}
print("PART 2", time)