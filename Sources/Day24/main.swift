import Foundation
import AdventOfCode
import FootlessParser

func curry<A,B,C,D,E,F,G>(_ fn: @escaping (A, B, C, D, E, F) -> G) -> (A) -> (B) -> (C) -> (D) -> (E) -> (F) -> G {
    return { a in { b in { c in { d in { e in { f in fn(a, b, c, d, e, f) } } } } } }
}
func curry<A,B,C,D,E,F,G,H>(_ fn: @escaping (A, B, C, D, E, F, G) -> H) -> (A) -> (B) -> (C) -> (D) -> (E) -> (F) -> (G) -> H {
    return { a in { b in { c in { d in { e in { f in { g in fn(a, b, c, d, e, f, g) } } } } } } }
}


struct Attack: OptionSet {
  let rawValue: Int

  static let radiation = Attack(rawValue: 1 << 0) 
  static let fire = Attack(rawValue: 1 << 1) 
  static let cold = Attack(rawValue: 1 << 2) 
  static let slashing = Attack(rawValue: 1 << 3) 
  static let bludgeoning = Attack(rawValue: 1 << 4) 

  static var parser: Parser<Character, Attack> {
    let parser: Parser<Character, Attack> = [ 
      "radiation": .radiation,
      "fire": .fire,
      "cold": .cold,
      "slashing": .slashing,
      "bludgeoning": .bludgeoning 
    ].parser
    return Attack.init <^> oneOrMore(parser <* optional(string(", ")))
  }
}

class GroupRef: Hashable {
  var group: Group
  var hashValue: Int { return group.id }
  init(_ group: Group) {
    self.group = group
  }
  static func == (lhs: GroupRef, rhs: GroupRef) -> Bool {
    return lhs.group.id == rhs.group.id
  }
}

struct Group {
  static var nextId = 0
  let id: Int
  var units: Int
  let hitPoints: Int

  let immuneTo: Attack
  let weakTo: Attack
  var power: Int
  let attack: Attack
  let initiative: Int

  init(units: Int, hitPoints: Int, immuneTo: Attack?, weakTo: Attack?, power: Int, attack: Attack, initiative: Int) {
    defer { Group.nextId += 1 }

    id = Group.nextId
    self.units = units
    self.hitPoints = hitPoints
    self.immuneTo = immuneTo ?? []
    self.weakTo = weakTo ?? []
    self.power = power
    self.attack = attack
    self.initiative = initiative
  }

  var effectivePower: Int { return power * units }

  static func targetOrder(_ lhs: Group, _ rhs: Group) -> Bool {
    return lhs.effectivePower == rhs.effectivePower ? lhs.initiative < rhs.initiative : lhs.effectivePower < rhs.effectivePower
  }

  func victimOrder(_ lhs: Group, _ rhs: Group) -> Bool {
    let lDamage = self.damage(victim: lhs)
    let rDamage = self.damage(victim: rhs)
    if lDamage == rDamage {
      if lhs.effectivePower == rhs.effectivePower {
        return lhs.initiative < rhs.initiative
      } else {
        return lhs.effectivePower < rhs.effectivePower
      }
    } else {
      return lDamage < rDamage 
    }
  }
  static func attackOrder(_ lhs: Group, _ rhs: Group) -> Bool {
    return lhs.initiative > rhs.initiative
  }

  func damage(victim: Group) -> Int {
    if victim.immuneTo.contains( self.attack ) { return 0 }
    if victim.weakTo.contains( self.attack ) { return 2 * effectivePower }
    return effectivePower
  }
}

func chooseTargets( immuneSystem: [GroupRef], infection: [GroupRef] ) -> [(attacker: GroupRef, victim: GroupRef)] {
  var attackers: [(immune: GroupRef?, infection: GroupRef?)] = []
  attackers.append(contentsOf: immuneSystem.map { ($0, nil) } )
  attackers.append(contentsOf: infection.map { (nil, $0) } )
  attackers.sort(by: { Group.targetOrder(($0.immune?.group ?? $0.infection?.group)!, ($1.immune?.group ?? $1.infection?.group)!) })
  attackers.reverse()

  var availableImmune = Set<GroupRef>( immuneSystem )
  var availableInfection = Set<GroupRef>( infection )
  var results: [(attacker: GroupRef, victim: GroupRef)] = []

  for i in attackers {
    if let attacker = i.immune, let victim = availableInfection.max(by: { attacker.group.victimOrder($0.group, $1.group) } ), attacker.group.damage(victim: victim.group) > 0 {
        availableInfection.remove( victim )
        results.append((attacker: attacker, victim: victim))
    }
    else if let attacker = i.infection, let victim = availableImmune.max(by: { attacker.group.victimOrder($0.group, $1.group) } ), attacker.group.damage(victim: victim.group) > 0 {
        availableImmune.remove( victim )
        results.append((attacker: attacker, victim: victim))
    }
  }

  return results.sorted { Group.attackOrder( $0.0.group, $1.0.group )}
}

func attack(_ round: [(attacker: GroupRef, victim: GroupRef)], immuneSystem: [GroupRef], infection: [GroupRef]) -> ([GroupRef], [GroupRef]) {
  for (attacker, victim) in round {
    if attacker.group.units > 0 {
      victim.group.units -= attacker.group.damage(victim: victim.group) / victim.group.hitPoints
    }
  }

  return (immuneSystem.filter { $0.group.units > 0 }, infection.filter { $0.group.units > 0 })
}

let parser = oneOrMore(
    ((curry({Group(units: $0, hitPoints: $1, immuneTo: [], weakTo: [], power: $2, attack: $3, initiative: $4)}) <^> unsignedInteger <*> ((string(" units each with ") *> unsignedInteger) <* string(" hit points with an attack that does ")) <*> unsignedInteger <*> (char(" ") *> Attack.parser <* string(" damage at initiative ")) <*> unsignedInteger) <|> 
     (curry({Group(units: $0, hitPoints: $1, immuneTo: $3, weakTo: $2, power: $4, attack: $5, initiative: $6)}) <^> unsignedInteger <*> ((string(" units each with ") *> unsignedInteger) <* string(" hit points ")) <*> (string("(weak to ") *> Attack.parser) <*> (optional(string("; immune to ") *> Attack.parser) <* char(")")) <*> (string(" with an attack that does ") *> unsignedInteger) <*> (char(" ") *> Attack.parser <* string(" damage at initiative ")) <*> unsignedInteger) <|>
     (curry({Group(units: $0, hitPoints: $1, immuneTo: $2, weakTo: $3, power: $4, attack: $5, initiative: $6)}) <^> unsignedInteger <*> ((string(" units each with ") *> unsignedInteger) <* string(" hit points ")) <*> (string("(immune to ") *> Attack.parser) <*> (optional(string("; weak to ") *> Attack.parser) <* char(")")) <*> (string(" with an attack that does ") *> unsignedInteger) <*> (char(" ") *> Attack.parser <* string(" damage at initiative ")) <*> unsignedInteger))
    <* optional(whitespace) )
let p = tuple <^> (string("Immune System: ") *> parser) <*> (string(" Infection: ") *> parser)
let (immuneSystem, infection) = try! parse( p, stdin.joined(separator: " ") )

func part1(immuneSystem: [Group], infection: [Group]) -> (Int, Int) {
  var immuneRef = immuneSystem.map { GroupRef($0) }
  var infectionRef = infection.map { GroupRef($0) }

  var prev = (immuneRef.reduce(0) { $0 + $1.group.units}, infectionRef.reduce(0) { $0 + $1.group.units })
  while !immuneRef.isEmpty && !infectionRef.isEmpty {
    let round = chooseTargets(immuneSystem: immuneRef, infection: infectionRef)
    if round.isEmpty { break }

    (immuneRef, infectionRef) = attack(round, immuneSystem: immuneRef, infection: infectionRef)
    let current = (immuneRef.reduce(0) { $0 + $1.group.units}, infectionRef.reduce(0) { $0 + $1.group.units })

    // It's possible that the attacker doesn't have enough attack power to kill their selected victim.
    if prev == current { break }

    prev = current
  }

  return (immuneRef.reduce(0) { $0 + $1.group.units }, infectionRef.reduce(0) { $0 + $1.group.units })
}

func part1(boost: Int, immuneSystem: [Group], infection: [Group]) -> (Int, Int) {
  let immune = immuneSystem.map { (group: Group) -> Group in
    var boosted = group
    boosted.power += boost
    return boosted
  }

  return part1(immuneSystem: immune, infection: infection)
}

func part2(immuneSystem: [Group], infection: [Group]) -> Int {
  let boost = (1..<256).first() { boost in 
    let result = part1(boost: boost, immuneSystem: immuneSystem, infection: infection)
    return result.0 > 0 && result.1 == 0
  }

  return part1(boost: boost!, immuneSystem: immuneSystem, infection: infection).0
}

print("PART 1", part1(immuneSystem: immuneSystem, infection: infection))
print("PART 2", part2(immuneSystem: immuneSystem, infection: infection))