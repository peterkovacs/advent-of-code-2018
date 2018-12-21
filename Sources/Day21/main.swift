import AdventOfCode
import Foundation
import FootlessParser

func part1() {
  var b = 0, c = 0, d = 0, f = 0

  f = c | 0x10000
  c = 0x4fdfac
  while true {
    d = f & 0xff
    c = d + c
    c = c & 0xffffff
    c = c * 65899
    c = c & 0xffffff

    if 256 > f {
      print("PART 1", c)
      return
    }

    d = 0
    while true {
      b = d + 1
      b = 256 * b
      if b > f {
        break
      }
      d = d + 1
    }
    f = d
  }
}

func part2() {
  var b = 0, c = 0, d = 0, f = 0
  var results = Set<Int>()
  var last = 0

  while true {
    f = c | 0x10000
    c = 0x4fdfac
    while true {
      d = f & 0xff
      c = d + c
      c = c & 0xffffff
      c = c * 65899
      c = c & 0xffffff

      if 256 > f {
        let (inserted, _) = results.insert(c)
        if inserted {
          last = c
        } else {
          print("PART 2", last)
          return
        }
        break
      }

      d = 0
      while true {
        b = d + 1
        b = 256 * b
        if b > f {
          break
        }
        d = d + 1
      }
      f = d
    }
  }
}

// part1()
// part2()

extension CPU {
  typealias BoundInstruction = (inout [Int]) -> ()
  static var parser: Parser<Character, BoundInstruction> {
    let instruction: Parser<Character, (inout [Int], Int, Int, Int) -> ()> = [
      "addr": CPU.addr, "addi": CPU.addi,
      "mulr": CPU.mulr, "muli": CPU.muli,
      "banr": CPU.banr, "bani": CPU.bani,
      "borr": CPU.borr, "bori": CPU.bori,
      "setr": CPU.setr, "seti": CPU.seti,
      "gtir": CPU.gtir, "gtri": CPU.gtri, "gtrr": CPU.gtrr,
      "eqir": CPU.eqir, "eqri": CPU.eqri, "eqrr": CPU.eqrr,
    ].parser

    return curry({ inst, a, b, c in { (registers: inout [Int]) in inst(&registers, a, b, c) } }) <^> 
      instruction <*> 
      (whitespaces *> unsignedInteger) <*>
      (whitespaces *> unsignedInteger) <*>
      (whitespaces *> unsignedInteger)
  }

  static let ip = 4
  func part1(code: [BoundInstruction]) -> CPU {
    var result = self
    while true {
      result.registers[CPU.ip] = CPU.pc
      code[CPU.pc](&result.registers)

      if CPU.pc == 29 { return result }

      CPU.pc = result.registers[CPU.ip] + 1
    }
  }

  func part2(code: [BoundInstruction]) -> CPU {
    var result = self
    var last = 0
    var numbers = Set<Int>()
    while true {
      result.registers[CPU.ip] = CPU.pc
      code[CPU.pc](&result.registers)

      if CPU.pc == 29 { 
        let (inserted, _) = numbers.insert(result.registers[2])
        if inserted {
          last = result.registers[2]
        } else {
          result.registers[2] = last
          return result
        }
      }

      CPU.pc = result.registers[CPU.ip] + 1
    }
  }
}

let instructions = stdin.map { try! parse( CPU.parser, $0 ) }
print("PART 1", CPU(registers: [Int](repeating: 0, count: 6)).part1(code: instructions).registers[2] )
print("PART 2", CPU(registers: [Int](repeating: 0, count: 6)).part2(code: instructions).registers[2] )