import AdventOfCode
import FootlessParser
import Foundation

func sumOfMetadata() -> Parser<Int, Int> {
  return Parser { input in
    let nChildren = try any().parse(&input)
    let nMetadata = try any().parse(&input)

    return try count( nChildren, sumOfMetadata() ).parse(&input).reduce(0, +) +
               count( nMetadata, any() ).parse(&input).reduce(0, +)
  }
}

func valueOfNodes() -> Parser<Int, Int> {
  return Parser { input in 
    let nChildren = try any().parse(&input)
    let nMetadata = try any().parse(&input)

    let children = try count( nChildren, valueOfNodes() ).parse(&input)
    let metadata = try count( nMetadata, any() ).parse(&input)

    if nChildren == 0 {
      return metadata.reduce(0, +)
    } else {
      return metadata.reduce(0) { $0 + (children.indices.contains($1 - 1) ? children[$1 - 1] : 0) }
    }
  }
}

let line = readLine(strippingNewline: true)!
let input = try! parse( oneOrMore( unsignedInteger <* optional( whitespaces ) ), line )
let part1 = try! parse( sumOfMetadata(), input )
print( "PART 1", part1 )
let part2 = try! parse( valueOfNodes(), input )
print( "PART 2", part2 )