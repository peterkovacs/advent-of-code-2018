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
while true {
  changes.forEach {
    frequency += $0
    if frequenciesReached.contains(frequency) {
      print(frequency)
      exit(0)
    }

    frequenciesReached.insert(frequency)
  }
}