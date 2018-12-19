import Foundation

public struct CPU: Equatable {
  public var registers: [Int]
  public static var pc: Int = 0
  public static let names = [ "a", "b", "c", "d", "ip", "f"]

  public init(registers: [Int]) {
    self.registers = registers
  }

  public func addr(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    print(CPU.pc, "ADDR", CPU.names[a], CPU.names[b], CPU.names[c], terminator:"")
    print("\t -- \(CPU.names[c]) = \(cpu.registers[a]) + \(cpu.registers[b])")
    cpu.registers[c] = cpu.registers[a] + cpu.registers[b]
    return cpu
  }
  public func addi(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    print(CPU.pc, "ADDI", CPU.names[a], b, CPU.names[c], terminator:"")
    print("\t -- \(CPU.names[c]) = \(cpu.registers[a]) + \(b)")
    cpu.registers[c] = cpu.registers[a] + b
    return cpu
  }

  public func mulr(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    print(CPU.pc, "MULR", CPU.names[a], CPU.names[b], CPU.names[c], terminator:"")
    print("\t -- \(CPU.names[c]) = \(cpu.registers[a]) * \(cpu.registers[b])")
    cpu.registers[c] = cpu.registers[a] * cpu.registers[b]
    return cpu
  }
  public func muli(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    print(CPU.pc, "MULI", CPU.names[a], b, CPU.names[c], terminator:"")
    print("\t -- \(CPU.names[c]) = \(cpu.registers[a]) * \(b)")
    cpu.registers[c] = cpu.registers[a] * b
    return cpu
  }

  public func banr(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    print(CPU.pc, "BANR", CPU.names[a], CPU.names[b], CPU.names[c], terminator:"")
    print("\t -- \(CPU.names[c]) = \(cpu.registers[a]) & \(cpu.registers[b])")
    cpu.registers[c] = cpu.registers[a] & cpu.registers[b]
    return cpu
  }
  public func bani(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    print(CPU.pc, "BANI", CPU.names[a], b, CPU.names[c], terminator:"")
    print("\t -- \(CPU.names[c]) = \(cpu.registers[a]) & \(b)")
    cpu.registers[c] = cpu.registers[a] & b
    return cpu
  }

  public func borr(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    print(CPU.pc, "BORR", CPU.names[a], CPU.names[b], CPU.names[c], terminator:"")
    print("\t -- \(CPU.names[c]) = \(cpu.registers[a]) | \(cpu.registers[b])")
    cpu.registers[c] = cpu.registers[a] | cpu.registers[b]
    return cpu
  }
  public func bori(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    print(CPU.pc, "BORI", CPU.names[a], b, CPU.names[c], terminator:"")
    print("\t -- \(CPU.names[c]) = \(cpu.registers[a]) | \(b)")
    cpu.registers[c] = cpu.registers[a] | b
    return cpu
  }

  public func setr(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    print(CPU.pc, "SETR", CPU.names[a], CPU.names[c], terminator:"")
    print("\t -- \(CPU.names[c]) = \(cpu.registers[a])")
    cpu.registers[c] = cpu.registers[a]
    return cpu
  }
  public func seti(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    print(CPU.pc, "SETI", a, CPU.names[c], terminator:"")
    print("\t -- \(CPU.names[c]) = \(a)")
    cpu.registers[c] = a
    return cpu
  }

  public func gtir(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    print(CPU.pc, "GTIR", a, CPU.names[b], CPU.names[c], terminator:"")
    print("\t -- \(CPU.names[c]) = \(a) > \(cpu.registers[b])")
    cpu.registers[c] = a > cpu.registers[b] ? 1 : 0
    return cpu
  }
  public func gtri(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    print(CPU.pc, "GTRI", CPU.names[a], b, CPU.names[c], terminator:"")
    print("\t -- \(CPU.names[c]) = \(cpu.registers[a]) > \(b)")
    cpu.registers[c] = cpu.registers[a] > b ? 1 : 0
    return cpu
  }
  public func gtrr(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    print(CPU.pc, "GTRR", CPU.names[a], CPU.names[b], CPU.names[c], terminator:"")
    print("\t -- \(CPU.names[c]) = \(cpu.registers[a]) > \(cpu.registers[b])")
    cpu.registers[c] = cpu.registers[a] > cpu.registers[b] ? 1 : 0
    return cpu
  }

  public func eqir(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    print(CPU.pc, "EQIR", a, CPU.names[b], CPU.names[c], terminator:"")
    print("\t -- \(CPU.names[c]) = \(a) == \(cpu.registers[b])")
    cpu.registers[c] = a == cpu.registers[b] ? 1 : 0
    return cpu
  }
  public func eqri(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    print(CPU.pc, "EQRI", CPU.names[a], b, CPU.names[c], terminator:"")
    print("\t -- \(CPU.names[c]) = \(cpu.registers[a]) == \(b)")
    cpu.registers[c] = cpu.registers[a] == b ? 1 : 0
    return cpu
  }
  public func eqrr(a: Int, b: Int, c: Int) -> CPU {
    var cpu = self
    print(CPU.pc, "EQRR", CPU.names[a], CPU.names[b], CPU.names[c], terminator:"")
    print("\t -- \(CPU.names[c]) = \(cpu.registers[a]) == \(cpu.registers[b])")
    cpu.registers[c] = cpu.registers[a] == cpu.registers[b] ? 1 : 0
    return cpu
  }

}