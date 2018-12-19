import FootlessParser
import AdventOfCode

extension CPU {
  static let ops = [ CPU.addi, CPU.addr, CPU.bani, CPU.banr, CPU.bori, CPU.borr, CPU.eqir, CPU.eqri, CPU.eqrr, CPU.gtir, CPU.gtri, CPU.gtrr, CPU.muli, CPU.mulr, CPU.seti, CPU.setr ]
  static var codes = [Int:Int]()

  func exec(op: [Int]) -> CPU {
    guard let instruction = CPU.codes[ op[0] ] else { fatalError() }
    return  CPU.ops[ instruction ]( self )(op[1], op[2], op[3])
  }

  static func determineOpCodes( samples: [([Int], [Int], [Int])] ) {
    var mapping = [Int:Set<Int>]()

    func reduceSingleton() {
      guard let (key, value) = mapping.first(where: { $0.value.count == 1 }) else { fatalError() }
      guard let instruction = value.first else { fatalError() }
      
      codes[key] = instruction
      mapping[key] = nil
      mapping = mapping.mapValues { 
        var s = $0
        s.remove(instruction)
        return s
      }
    }

    for (before, code, after) in samples {
      for (instruction, method) in CPU.ops.enumerated() {
        if method( CPU(registers: before) )( code[1], code[2], code[3] ) == CPU(registers: after) {
          mapping[code[0], default: Set<Int>()].insert(instruction)
        }
      }
    }

    while !mapping.isEmpty {
      reduceSingleton()
    }
  }
}

let registers = char("[") *> (count(4, unsignedInteger <* optional(string(", "))) <* char("]"))
let operation = count(4, unsignedInteger <* optional(char(" ")))
let before = string("Before: ") *> registers
let after  = string("After:  ") *> registers
let parser = tuple <^> oneOrMore( tuple <^> (before <* whitespaces) <*> operation <*> (after <* whitespaces) ) <*> oneOrMore( operation <* optional(whitespace) )
let (samples, program) = try! parse( parser, stdin.joined(separator: " ") )

let part1 = samples.filter {
  let (before, code, after) = $0
  return CPU.ops.reduce(0) { 
    $0 + (($1( CPU(registers: before) )( code[1], code[2], code[3] ) == CPU(registers: after)) ? 1 : 0)
  } > 2
}.count

print("PART 1", part1)

CPU.determineOpCodes(samples: samples)
print("PART 2", program.reduce( CPU(registers: [0, 0, 0, 0]) ) { $0.exec(op: $1) }.registers[0] )