import Foundation

public let stdin = sequence( state: (), next: { _ in readLine( strippingNewline: true ) } )
public func infinite<C: Collection>(_ data: C) -> UnfoldSequence<C.Element, C.Index> {
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