import Foundation

public let stdin = sequence( state: (), next: { _ in readLine( strippingNewline: true ) } )

public func cycle<C: Collection>(_ data: C) -> UnfoldSequence<C.Element, C.Index> {
  return sequence(state: data.startIndex) { (last: inout C.Index) in 
    guard last != data.endIndex else { return nil }

    defer {
      last = data.index(after: last)
      if last == data.endIndex {
        last = data.startIndex
      }
    }
    return data[last]
  }
}

public func accumulate<S: Sequence>( _ data: S, initial: S.Element = 0, _ op: @escaping (S.Element, S.Element) -> S.Element ) -> UnfoldSequence<S.Element, (S.Element, S.Iterator)> where S.Element: Numeric {
  return sequence(state: (initial, data.makeIterator())) { (state: inout (S.Element, S.Iterator)) in
    var (prev, iter) = state
    guard let val = iter.next() else { return nil }
    state = ( op(prev, val), iter )

    return state.0
  }
}