import Foundation
import AdventOfCode
import FootlessParser

enum Halt: Error {
  case done(CPU)
}

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
  func exec(code: [BoundInstruction]) -> CPU {
    var result = self
    while true {
      result.registers[CPU.ip] = CPU.pc
      code[CPU.pc](&result.registers)
      CPU.pc = result.registers[CPU.ip] + 1

      guard code.indices.contains(CPU.pc) else { return result }
    }
  }
}

// #ip 4
let instructions = stdin.map { try! parse( CPU.parser, $0 ) }
let cpu = CPU(registers: [Int](repeating: 0, count: 6)).exec(code: instructions)
print(cpu)