import CZ3
import Tagged

public struct Z3Context {
  public var config: Z3_config!
  public var context: Z3_context!

  public init() {
    config = Z3_mk_config()
    context = Z3_mk_context(config)
  }

  public init(config: Z3_config?, context: Z3_context?) {
    self.config = config
    self.context = context
  }

  public func optimize() -> Z3_optimize? {
    return Z3_mk_optimize(context)
  }
  public func Int(named name: String) -> Z3_ast? {
    let type = Z3_mk_int_sort(self.context)
    let symbol = Z3_mk_string_symbol(self.context, name)
    return Z3_mk_const(self.context, symbol, type)
  }

  public func Int32(_ value: Int) -> Z3_ast? {
    precondition((Swift.Int(Swift.Int32.min)...Swift.Int(Swift.Int32.max)).contains(value))
    let type = Z3_mk_int_sort(self.context)
    return Z3_mk_int(self.context, Swift.Int32(value), type)
  }

  public func Int32(_ value: Int32) -> Z3_ast? {
    let type = Z3_mk_int_sort(self.context)
    return Z3_mk_int(self.context, value, type)
  }

  public func Int64(_ value: Int64) -> Z3_ast? {
    let type = Z3_mk_int_sort(self.context)
    return Z3_mk_int64(self.context, value, type)
  }

  public func UInt32(_ value: UInt32) -> Z3_ast? {
    let type = Z3_mk_int_sort(self.context)
    return Z3_mk_unsigned_int(self.context, value, type)
  }

  public func UInt64(_ value: UInt64) -> Z3_ast? {
    let type = Z3_mk_int_sort(self.context)
    return Z3_mk_unsigned_int64(self.context, value, type)
  }

}

extension Z3_ast: CustomStringConvertible {
  public var description: String {
    return String(cString: Z3_get_numeral_string( Z3.context, self))
  }
}

public func abs(_ val: Z3_ast!) -> Z3_ast? {
  return If(val > Z3.Int32(0), then: val, else: -val)
}

public func If(_ expr: Z3_ast!, then: Z3_ast!, else otherwise: Z3_ast!) -> Z3_ast? {
  return Z3_mk_ite(Z3.context, expr, then, otherwise)
}




public enum OptimizationIndex {}

public extension Z3_optimize {
  public func add(_ ast: Z3_ast!) {
    Z3_optimize_assert(Z3.context, self, ast)
  }

  // TODO: Make this tagged.
  public func minimize(_ ast: Z3_ast!) -> Tagged<OptimizationIndex,UInt32> {
    return Tagged<OptimizationIndex,UInt32>(rawValue: Z3_optimize_minimize(Z3.context, self, ast))
  }

  public func maximize(_ ast: Z3_ast!) -> Tagged<OptimizationIndex,UInt32> {
    return Tagged<OptimizationIndex,UInt32>(rawValue: Z3_optimize_maximize(Z3.context, self, ast))
  }

  public func check() -> Bool {
    return Z3_optimize_check(Z3.context, self, 0, nil) == Z3_lbool(1)
  }

  public func lower(_ index: Tagged<OptimizationIndex,UInt32>) -> Z3_ast? {
    return Z3_optimize_get_lower(Z3.context, self, index.rawValue)
  }
  
  public func upper(_ index: Tagged<OptimizationIndex,UInt32>) -> Z3_ast? {
    return Z3_optimize_get_upper(Z3.context, self, index.rawValue)
  }
}

public extension Array where Element == Z3_ast? {
  public func sum() -> Z3_ast? {
    return withUnsafeBufferPointer { ptr in 
      Z3_mk_add(Z3.context, UInt32(self.count), ptr.baseAddress)
    }
  }

  public func product() -> Z3_ast? {
    return withUnsafeBufferPointer { ptr in 
      Z3_mk_mul(Z3.context, UInt32(self.count), ptr.baseAddress)
    }
  }

  public func difference() -> Z3_ast? {
    return withUnsafeBufferPointer { ptr in 
      Z3_mk_sub(Z3.context, UInt32(self.count), ptr.baseAddress)
    }
  }

  public func distinct() -> Z3_ast? {
    return withUnsafeBufferPointer { ptr in 
      Z3_mk_distinct(Z3.context, UInt32(self.count), ptr.baseAddress)
    }
  }

  public func and() -> Z3_ast? {
    return withUnsafeBufferPointer { ptr in 
      Z3_mk_and(Z3.context, UInt32(self.count), ptr.baseAddress)
    }
  }

  public func or() -> Z3_ast? {
    return withUnsafeBufferPointer { ptr in 
      Z3_mk_or(Z3.context, UInt32(self.count), ptr.baseAddress)
    }
  }
}

public var Z3 = Z3Context()

public func +(lhs: Z3_ast!, rhs: Z3_ast!) -> Z3_ast? {
    return Z3_mk_add(Z3.context, 2, [lhs, rhs])
}
public func -(lhs: Z3_ast!, rhs: Z3_ast!) -> Z3_ast? {
    return Z3_mk_sub(Z3.context, 2, [lhs, rhs])
}
public prefix func -(lhs: Z3_ast!) -> Z3_ast? {
    return Z3_mk_unary_minus(Z3.context, lhs)
}
public func *(lhs: Z3_ast!, rhs: Z3_ast!) -> Z3_ast? {
    return Z3_mk_mul(Z3.context, 2, [lhs, rhs])
}
public func /(lhs: Z3_ast!, rhs: Z3_ast!) -> Z3_ast? {
    return Z3_mk_div(Z3.context, lhs, rhs)
}
public func %(lhs: Z3_ast!, rhs: Z3_ast!) -> Z3_ast? {
    return Z3_mk_mod(Z3.context, lhs, rhs)
}
public func &(lhs: Z3_ast!, rhs: Z3_ast!) -> Z3_ast? {
    return Z3_mk_and(Z3.context, 2, [lhs, rhs])
}
public func |(lhs: Z3_ast!, rhs: Z3_ast!) -> Z3_ast? {
    return Z3_mk_or(Z3.context, 2, [lhs, rhs])
}
public func ^(lhs: Z3_ast!, rhs: Z3_ast!) -> Z3_ast? {
    return Z3_mk_xor(Z3.context, lhs, rhs)
}
public func ==(lhs: Z3_ast!, rhs: Z3_ast!) -> Z3_ast? {
    return Z3_mk_eq(Z3.context, lhs, rhs)
}
public func <=(lhs: Z3_ast!, rhs: Z3_ast!) -> Z3_ast? {
    return Z3_mk_le(Z3.context, lhs, rhs)
}
public func >=(lhs: Z3_ast!, rhs: Z3_ast!) -> Z3_ast? {
    return Z3_mk_ge(Z3.context, lhs, rhs)
}
public func >(lhs: Z3_ast!, rhs: Z3_ast!) -> Z3_ast? {
    return Z3_mk_gt(Z3.context, lhs, rhs)
}
public func <(lhs: Z3_ast!, rhs: Z3_ast!) -> Z3_ast? {
    return Z3_mk_lt(Z3.context, lhs, rhs)
}