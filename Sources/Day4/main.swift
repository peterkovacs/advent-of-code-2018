import Foundation
import AdventOfCode
import FootlessParser

let dateParser = DateFormatter()
dateParser.dateFormat = "yyyy-MM-dd HH:mm"
dateParser.timeZone = TimeZone(identifier: "UTC")!

var calendar = Calendar.current
calendar.timeZone = TimeZone(identifier: "UTC")!

enum Log: Comparable, Equatable {
  case begin(Date, Int)
  case asleep(Date)
  case wakeup(Date)

  static func <(lhs: Log, rhs: Log) -> Bool {
    let a: Date
    let b: Date
    switch lhs { case .begin(let d, _), .asleep(let d), .wakeup(let d): a = d }
    switch rhs { case .begin(let d, _), .asleep(let d), .wakeup(let d): b = d }
    return a < b
  }
}

struct Shift {
  let id: Int
  let asleep: [Range<Int>]
}

extension Date {
  func range(to date: Date) -> Range<Int> {
    return calendar.component(.minute, from: self)..<calendar.component(.minute, from: date)
  }
}

func parse() -> [Shift] {
  let date = { dateParser.date(from:$0)! } <^> ((char("[")) *> oneOrMore(not("]" as Character))) <* (char("]") <* whitespaces)
  let begin = curry(Log.begin) <^> date <*> (string("Guard #") *> integer) <* string( " begins shift")
  let asleep = Log.asleep <^> date <* string("falls asleep")
  let wakeup = Log.wakeup <^> date <* string("wakes up")
  let log = begin <|> asleep <|> wakeup

  let `guard`: Parser<Log, Int> = any() >>- { 
    guard case .begin(_, let id) = $0 else { return fail( .Mismatch(Remainder([$0]), ".begin", String(describing: $0))) }
    return pure(id)
  }

  let sleeping: Parser<Log, Range<Int>> = count(2, any()) >>- { tokens in 
    switch (tokens[0], tokens[1]) {
      case (.asleep(let d), .wakeup(let e)): 
        return pure(d.range(to: e))
      default: 
        return fail( .Mismatch(Remainder(tokens), ".asleep, .wakeup", String(describing: tokens)))
    }
  }

  let shift = curry(Shift.init(id:asleep:)) <^> `guard` <*> zeroOrMore(sleeping)
  let logs = stdin.map { try! FootlessParser.parse( log, $0 ) }.sorted()

  return try! FootlessParser.parse(oneOrMore(shift), logs)
}

let guards = Dictionary(grouping: parse(), by: { $0.id }).mapValues { 
  $0.reduce([Int](repeating: 0, count: 60)) { 
    $1.asleep.reduce($0) { 
      var minutes = $0
      for i in $1 {
        minutes[i] += 1
      }
      return minutes
    }
  } 
}

let sleepy = guards.max(by: { $0.value.sum() < $1.value.sum() })!
print("PART 1", sleepy.key * (sleepy.value.firstIndex(of: sleepy.value.max()!)!))

let consistent = guards.max(by: { $0.value.max()! < $1.value.max()! })!
print("PART 2", consistent.key * (consistent.value.firstIndex(of: consistent.value.max()!)!))