import Foundation

public struct CPU: Equatable {
  public var registers: [Int]
  public static var pc: Int = 0
  // public static let names = [ "a", "b", "c", "d", "ip", "f"]

  public init(registers: [Int]) {
    self.registers = registers
  }

  public static func addr(registers: inout [Int], a: Int, b: Int, c: Int) {
    registers[c] = registers[a] + registers[b]
  }
  public func addr(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    CPU.addr(registers: &cpu.registers, a: a, b: b, c: c)
    return cpu
  }

  public static func addi(registers: inout [Int], a: Int, b: Int, c: Int) {
    registers[c] = registers[a] + b
  }
  public func addi(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    CPU.addi(registers: &cpu.registers, a: a, b: b, c: c)
    return cpu
  }

  public static func mulr(registers: inout [Int], a: Int, b: Int, c: Int) {
    registers[c] = registers[a] * registers[b]
  }
  public func mulr(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    CPU.mulr(registers: &cpu.registers, a: a, b: b, c: c)
    return cpu
  }

  public static func muli(registers: inout [Int], a: Int, b: Int, c: Int) {
    registers[c] = registers[a] * b
  }
  public func muli(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    CPU.muli(registers: &cpu.registers, a: a, b: b, c: c)
    return cpu
  }

  public static func banr(registers: inout [Int], a: Int, b: Int, c: Int) {
    registers[c] = registers[a] & registers[b]
  }
  public func banr(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    CPU.banr(registers: &cpu.registers, a: a, b: b, c: c)
    return cpu
  }
  public static func bani(registers: inout [Int], a: Int, b: Int, c: Int) {
    registers[c] = registers[a] & b
  }
  public func bani(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    CPU.bani(registers: &cpu.registers, a: a, b: b, c: c)
    return cpu
  }
  public static func borr(registers: inout [Int], a: Int, b: Int, c: Int) {
    registers[c] = registers[a] | registers[b]
  }
  public func borr(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    CPU.borr(registers: &cpu.registers, a: a, b: b, c: c)
    return cpu
  }

  public static func bori(registers: inout [Int], a: Int, b: Int, c: Int) {
    registers[c] = registers[a] | b
  }
  public func bori(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    CPU.borr(registers: &cpu.registers, a: a, b: b, c: c)
    return cpu
  }

  public static func setr(registers: inout [Int], a: Int, b: Int, c: Int) {
    registers[c] = registers[a]
  }
  public func setr(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    CPU.setr(registers: &cpu.registers, a: a, b: b, c: c)
    return cpu
  }
  public static func seti(registers: inout [Int], a: Int, b: Int, c: Int) {
    registers[c] = a
  }
  public func seti(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    CPU.seti(registers: &cpu.registers, a: a, b: b, c: c)
    return cpu
  }

  public static func gtir(registers: inout [Int], a: Int, b: Int, c: Int) {
    registers[c] = a > registers[b] ? 1 : 0
  }
  public func gtir(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    CPU.gtir(registers: &cpu.registers, a: a, b: b, c: c)
    return cpu
  }

  public static func gtri(registers: inout [Int], a: Int, b: Int, c: Int) {
    registers[c] = registers[a] > b ? 1 : 0
  }
  public func gtri(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    CPU.gtri(registers: &cpu.registers, a: a, b: b, c: c)
    return cpu
  }

  public static func gtrr(registers: inout [Int], a: Int, b: Int, c: Int) {
    registers[c] = registers[a] > registers[b] ? 1 : 0
  }
  public func gtrr(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    CPU.gtrr(registers: &cpu.registers, a: a, b: b, c: c)
    return cpu
  }

  public static func eqir(registers: inout [Int], a: Int, b: Int, c: Int) {
    registers[c] = a == registers[b] ? 1 : 0
  }
  public func eqir(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    CPU.eqir(registers: &cpu.registers, a: a, b: b, c: c)
    return cpu
  }

  public static func eqri(registers: inout [Int], a: Int, b: Int, c: Int) {
    registers[c] = registers[a] == b ? 1 : 0
  }
  public func eqri(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    CPU.eqri(registers: &cpu.registers, a: a, b: b, c: c)
    return cpu
  }

  public static func eqrr(registers: inout [Int], a: Int, b: Int, c: Int) {
    registers[c] = registers[a] == registers[b] ? 1 : 0
  }
  public func eqrr(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    CPU.eqrr(registers: &cpu.registers, a: a, b: b, c: c)
    return cpu
  }

}