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

extension Sequence where Element: Hashable {
  public func duplicates() -> [Self.Element]? {
    let duplicates = self.reduce(into: [:]) { $0[$1, default:0] += 1 }.filter { $0.value > 1 }.keys
    if duplicates.count > 0 {
      return Array(duplicates)
    } else {
      return nil
    }
  }
}

public struct CombinationIterator<Element> : IteratorProtocol {
  private let coll: [Element]
  private var curr: [Element]
  private var inds: [Int]

  mutating public func next() -> [Element]? {
    for (max, curInd) in zip(coll.indices.reversed(), inds.indices.reversed()) where max != inds[curInd] {
        inds[curInd] += 1
        curr[curInd] = coll[inds[curInd]]
        for j in inds.indices.dropFirst(curInd + 1) {
          inds[j] = inds[j-1].advanced(by: 1)
          curr[j] = coll[inds[j]]
        }
        return curr
    }
    return nil
  }

  internal init( coll: [Element], curr: [Element], inds: [Int] ) {
    self.coll = coll
    self.curr = curr
    self.inds = inds
  }
}

/// :nodoc:
public struct CombinationSequence<Element> : LazySequenceProtocol {
  public typealias Iterator = CombinationIterator<Element>
  
  private let start: [Element]
  private let col  : [Element]
  private let inds : [Int]
  /// :nodoc:
  public func makeIterator() -> Iterator {
    let result = Iterator(coll: col, curr: start, inds: inds)
    return result
  }
  
  internal init(n: Int, col: [Element]) {
    self.col = col
    start = Array(col.prefix(upTo:n))
    var inds = Array(col.indices.prefix(upTo:n))
    if !inds.isEmpty {
      inds[n.advanced(by: -1)] -= 1
    }
    self.inds = inds
  }
}
/// :nodoc:
public struct RepeatingCombinationIterator<Element> : IteratorProtocol {
  
  private let coll: [Element]
  private var curr: [Element]
  private var inds: [Int]
  private let max : Int
  /// :nodoc:
  mutating public func next() -> [Element]? {
    for curInd in inds.indices.reversed() where max != inds[curInd] {
      inds[curInd] += 1
      curr[curInd] = coll[inds[curInd]]
      for j in (curInd+1)..<inds.count {
        inds[j] = inds[j-1]
        curr[j] = coll[inds[j]]
      }
      return curr
    }
    return nil
  }

  internal init( coll: [Element], curr: [Element], inds: [Int], max: Int ) {
    self.coll = coll
    self.curr = curr
    self.inds = inds
    self.max = max
  }
}
/// :nodoc:
public struct RepeatingCombinationSequence<Element> : LazySequenceProtocol {
  
  private let start: [Element]
  private let inds : [Int]
  private let col  : [Element]
  private let max  : Int
  /// :nodoc:
  public func makeIterator() -> RepeatingCombinationIterator<Element> {
    return RepeatingCombinationIterator(coll: col, curr: start, inds: inds, max: max)
  }
  
  internal init(n: Int, col: [Element]) {
    self.col = col
    start = col.first.map { x in Array(repeating: x, count: n) } ?? []
    var inds = Array(repeating: col.startIndex, count: n)
    if !inds.isEmpty { inds[n-1] -= 1 }
    self.inds = inds
    max = col.endIndex.advanced(by: -1)
  }
}


extension Sequence {
  /**
  Returns the combinations without repetition of length `n` of `self`, generated lazily
  and on-demand
  */
  public func combinations(length n: Int) -> CombinationSequence<Iterator.Element> {
    return CombinationSequence(n: n, col: Array(self))
  }
  /**
  Returns the combinations with repetition of length `n` of `self`, generated lazily and
  on-demand
  */
  public func repeatingCombinations(length n: Int) -> RepeatingCombinationSequence<Element> {
    return RepeatingCombinationSequence(n: n, col: Array(self))
  }
}

extension Sequence {
  public func permutations() -> PermutationIterator<Self> {
    return PermutationIterator(elements: self)
  }
}

public struct PermutationIterator<C: Sequence>: Sequence, IteratorProtocol {
  public typealias Element = [C.Element]
  var elements: Element
  var index: [Int]
  var i: Int = 1
  let N: Int
  var initial: Bool = true

  init( elements: C ) {
    self.elements = Array(elements)
    self.N = self.elements.count
    self.index = [Int](repeating: 0, count: self.N)
  }

  public mutating func next() -> Element? {
    if initial {
      initial = false
      return elements
    }

    while i < N {
      if index[i] < i {
        let swap = i % 2 * index[i]
        let tmp = elements[swap]
        elements[swap] = elements[i]
        elements[i] = tmp

        defer {
          index[i] += 1
          i = 1
        }

        return elements
      } else {
        defer { i += 1 }
        index[i] = 0
      }
    }

    return nil
  }
}
