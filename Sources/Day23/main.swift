import AdventOfCode
import FootlessParser
import CZ3

struct World {
    let config: Z3_config!
    let context: Z3_context!
    let optimize: Z3_optimize!

    init() {
        config = Z3_mk_config()
        context = Z3_mk_context(config)
        optimize = Z3_mk_optimize(context)
    }
}

let Current = World()

extension Sequence {
  func count(where condition: (Element) throws -> Bool ) rethrows -> Int {
    return try reduce(into: 0) { if try condition($1) { $0 += 1 } }
  }
}

func +(lhs: Z3_ast!, rhs: Z3_ast!) -> Z3_ast? {
    return Z3_mk_add(Current.context, 2, [lhs, rhs])
}
func -(lhs: Z3_ast!, rhs: Z3_ast!) -> Z3_ast? {
    return Z3_mk_sub(Current.context, 2, [lhs, rhs])
}
func ==(lhs: Z3_ast!, rhs: Z3_ast!) -> Z3_ast? {
    return Z3_mk_eq(Current.context, lhs, rhs)
}

func <=(lhs: Z3_ast!, rhs: Z3_ast!) -> Z3_ast? {
    return Z3_mk_le(Current.context, lhs, rhs)
}
func >=(lhs: Z3_ast!, rhs: Z3_ast!) -> Z3_ast? {
    return Z3_mk_ge(Current.context, lhs, rhs)
}

func >(lhs: Z3_ast!, rhs: Z3_ast!) -> Z3_ast? {
    return Z3_mk_gt(Current.context, lhs, rhs)
}
func <(lhs: Z3_ast!, rhs: Z3_ast!) -> Z3_ast? {
    return Z3_mk_lt(Current.context, lhs, rhs)
}


func Int(name: String) -> Z3_ast? {
    let type = Z3_mk_int_sort(Current.context)
    let symbol = Z3_mk_string_symbol(Current.context, name)
    return Z3_mk_const(Current.context, symbol, type)
}

func Int(_ value: Int) -> Z3_ast? {
    let type = Z3_mk_int_sort(Current.context)
    return Z3_mk_int(Current.context, Int32(value), type)
}


func abs(_ l: Z3_ast!) -> Z3_ast? {
    return Z3_mk_ite(Current.context, l > Int(0), l, Int(0) - l)
}

func If(_ expr: Z3_ast!, then: Z3_ast!, else otherwise: Z3_ast!) -> Z3_ast? {
    return Z3_mk_ite(Current.context, expr, then, otherwise)
}

extension Z3_optimize {
    func add(_ ast: Z3_ast!) {
        Z3_optimize_assert(Current.context, self, ast)
    }

    func maximize(_ ast: Z3_ast!) -> UInt32 {
        return Z3_optimize_maximize(Current.context, self, ast)
    }

    func minimize(_ ast: Z3_ast!) -> UInt32 {
        return Z3_optimize_minimize(Current.context, self, ast)
    }
    func check() -> Bool {
        return Z3_optimize_check(Current.context, self, 0, nil) == Z3_lbool(1)
    }
}

extension Array where Element == Z3_ast? {
    var sum: Z3_ast? {
        return self.withUnsafeBufferPointer { ptr in
            Z3_mk_add(Current.context, UInt32(self.count), ptr.baseAddress)
        }
    }
}

struct P4 {
  let x, y, z, r: Int

  static var parser: Parser<Character, P4> {
    return curry(P4.init) <^> (string("pos=<") *> integer) <*> (char(",") *> integer) <*> (char(",") *> integer <* char(">")) <*> (string(", r=") *> unsignedInteger)
  }

  static func - (lhs: P4, rhs: P4) -> Int {
    let x = abs(lhs.x - rhs.x)
    let y = abs(lhs.y - rhs.y)
    let z = abs(lhs.z - rhs.z)
    return x + y + z
  }
}

let points = stdin.compactMap { try? parse(P4.parser, $0) }
if let max = points.max(by: { $0.r < $1.r }) {
  print("PART 1", points.count(where: { max - $0 <= max.r }))
}

let (x, y, z) = (Int(name: "x"), Int(name: "y"), Int(name: "z"))
let inRanges = points.indices.map { Int(name: "in_range_\($0)") }
let sum = Int(name: "sum")
let distance = Int(name: "distance")

for (i, point) in points.enumerated() {
    Current.optimize.add(inRanges[i] == If(abs(x - Int(point.x)) + abs(y - Int(point.y)) + abs(z - Int(point.z)) <= Int(point.r), then: Int(1), else: Int(0)))
}

Current.optimize.add( sum == inRanges.sum )
Current.optimize.add( distance == abs(x) + abs(y) + abs(z) )

let num = Current.optimize.maximize(sum)
let dist = Current.optimize.minimize(distance)

if Current.optimize.check() {
  print( "PART 2",
        String(cString: Z3_get_numeral_string( Current.context, Z3_optimize_get_lower(Current.context, Current.optimize, dist) )),
        String(cString: Z3_get_numeral_string( Current.context, Z3_optimize_get_upper(Current.context, Current.optimize, dist) )))
}