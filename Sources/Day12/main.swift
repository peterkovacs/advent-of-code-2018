import FootlessParser
import Foundation
import AdventOfCode

let bit = (char("#") >>- {_ in pure(1)}) <|> (char(".") >>- {_ in pure(0)})
let lookup = { a in return (a[0] << 4 | a[1] << 3 | a[2] << 2 | a[3] << 1 | a[4]) } <^> count(5, bit)
let transition = tuple <^> (lookup <* string(" => ")) <*> bit

let transitions = stdin.reduce(into: [Int](repeating: 0, count: 32)) {
  let (i, val) = try! parse(transition, $1)
  $0[i] = val
}

struct Planters {
  var plants: [Int]
  var zero: Int

  init(_ initial: [Int]) {
    plants = initial
    zero = 0
  }

  func next(at i: Int) -> Int {
    let range = (i-2)...(i+2)

    let val = range.reduce(0) { accum, i in
      if plants.indices.contains(i) && plants[i] > 0 {
        return (accum << 1) | 1
      } else {
        return accum << 1
      }
    }

    return transitions[val]
  }

  func next() -> Planters {
    var working = self

    if working.plants[0] == 1 || working.plants[1] == 1 {
      working.plants.insert(contentsOf: [0, 0], at: working.plants.startIndex)
      working.zero += 2
    } else if working.plants[0] == 0 && working.plants[1] == 0 {
      working.plants = Array(working.plants.dropFirst())
      working.zero -= 1
    }

    if working.plants[ working.plants.count - 2 ] == 1 || working.plants[ working.plants.count - 1 ] == 1 {
      working.plants += [0,0]
    }

    working.plants = working.plants.indices.map(working.next)

    return working
  }

  var sum: Int {
    return plants.enumerated().reduce(0) { $0 + (($1.element > 0) ? ($1.offset - zero) : 0) }
  }
}

// var plants = try! parse( Planters.init <^> oneOrMore(bit), "#..#.#..##......###...###" )
let input = try! parse( Planters.init <^> oneOrMore(bit), ".##.##...#.###..#.#..##..###..##...####.#...#.##....##.#.#...#...###.........##...###.....##.##.##" )

var part1 = input
for _ in 0..<20 {
  part1 = part1.next()
}

print("PART 1", part1.sum )

var part2 = input
for i in 1...10000 {
  part2 = part2.next()
  if i % 1000 == 0 {
    print("PART 2", i, part2.sum )
  }
}

print("PART 2", 50000000000 * 5 + 219 )