import Foundation
import AdventOfCode
import FootlessParser

enum Halt: Error {
  case done(CPU)
}

extension CPU {
  typealias BoundInstruction = (CPU) -> CPU
  static var parser: Parser<Character, BoundInstruction> {
    let instruction: Parser<Character, (CPU) -> (Int, Int, Int) -> CPU> = [
      "addr": CPU.addr, "addi": CPU.addi,
      "mulr": CPU.mulr, "muli": CPU.muli,
      "banr": CPU.banr, "bani": CPU.bani,
      "borr": CPU.borr, "bori": CPU.bori,
      "setr": CPU.setr, "seti": CPU.seti,
      "gtir": CPU.gtir, "gtri": CPU.gtri, "gtrr": CPU.gtrr,
      "eqir": CPU.eqir, "eqri": CPU.eqri, "eqrr": CPU.eqrr,
    ].parser

    return curry({ inst, a, b, c in { (cpu: CPU) in inst(cpu)(a, b, c) } }) <^> 
      instruction <*> 
      (whitespaces *> unsignedInteger) <*>
      (whitespaces *> unsignedInteger) <*>
      (whitespaces *> unsignedInteger)
  }

  static let ip = 4
  func exec(code: [BoundInstruction]) throws -> CPU {
    guard code.indices.contains(CPU.pc) else { throw Halt.done(self) }
    var result = self
    result.registers[CPU.ip] = CPU.pc
    result = code[CPU.pc](result)
    CPU.pc = result.registers[CPU.ip] + 1
    return result
  }
}

// #ip 4
let instructions = stdin.map { try! parse( CPU.parser, $0 ) }
var cpu = CPU(registers: [Int](repeating: 0, count: 6))
do {
  while true {
    cpu = try cpu.exec(code: instructions)
  }
} catch Halt.done(let e) {
  print( "PART 1", e.registers )
}