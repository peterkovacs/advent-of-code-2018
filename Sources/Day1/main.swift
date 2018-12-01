import AdventOfCode
import FootlessParser
import CommonCrypto

let signedInteger = { Int($0)! } <^> (extend <^> (char("+") <|> char("-")) <*> oneOrMore(digit))
let startingFrequency = 0
let changes = stdin.map { try! FootlessParser.parse(signedInteger, $0) }

print("PART 1")
print(changes.reduce(startingFrequency, +))

print("PART 2")
var frequenciesReached = Set<Int>()
var frequency = 0
print( accumulate(cycle(changes), +).lazy.first { val in
  defer { frequenciesReached.insert(val) }
  return frequenciesReached.contains(val)
} ?? 0 )