import AdventOfCode
import FootlessParser

let input = Array(stdin)
let part1 = input.map { Array($0).reduce(into: [:]) { $0[$1,default:0] += 1 } }
let twos = part1.filter { $0.values.first { $0 == 2 } != nil }.count
let threes = part1.filter { $0.values.first { $0 == 3 } != nil }.count

print( "PART 1", twos * threes )

func removing(index i: Int, in input: [String] ) -> [String] {
  return input.map { (s: String) in 
    var s = s
    s.remove(at: s.index(s.startIndex, offsetBy: i))
    return s
  }
}

for i in 0..<input[0].count {
  if let replaced = removing(index: i, in: input).duplicates() {
    print( "PART 2", replaced )
  }
}