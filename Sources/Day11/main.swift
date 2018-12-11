import AdventOfCode
import Foundation

func power(at coords: (Int, Int), serial: Int) -> Int {
  let rackId = coords.0 + 10
  var powerLevel = rackId * coords.1
  powerLevel += serial
  powerLevel *= rackId
  powerLevel /= 100
  powerLevel %= 10
  powerLevel -= 5
  return powerLevel
}

func square( at coords: (Int, Int), serial: Int, size: Int = 3 ) -> Int {
  return 
    iterate( 0..<size, and: 0..<size ).reduce(0) {
      $0 + power( at: (coords.0 + $1.0, coords.1 + $1.1), serial: serial )
    }
}

// Finds the maximum powered square *size* starting at coords
// (x, y, size, power)
func best( at coords: (Int, Int), serial: Int ) -> (Int, Int, Int, Int) {
  let single = power(at: (coords.0, coords.1), serial: serial)
  let maxSize = 300 - max( coords.0, coords.1 )
  guard maxSize > 0 else { 
    return (coords.0, coords.1, 1, single) 
  }

  let initial = (coords.0, coords.1, single, (1, single))
  let (x, y, _, (size, value)) = (1...maxSize).reduce(initial) { accum, size in
    let (x, y, prev, best) = accum

    let val = ( 0..<size ).reduce(prev) { 
      $0 + power(at: (x +    $1, y +  size), serial: serial) + 
           power(at: (x +  size, y +    $1), serial: serial) 
    }    + power(at: (x +  size, y +  size), serial: serial)

    if val > best.1 {
      return (x, y, val, (size + 1, val)) 
    } else {
      return (x, y, val, best)
    }
  }

  return (x, y, size, value)
}

func best( serial: Int ) -> (Int,Int,Int,Int) {
  return iterate( 1...300, and: 1...300 ).map { coord in 
    return best(at: coord, serial: serial)
  }.max { $0.3 < $1.3 }!
}

assert( power(at: (122,79), serial: 57) == -5 )
assert( power(at: (217,196), serial: 39) == 0 )
assert( power(at: (101,153), serial: 71) == 4 )
assert( square(at: (33,45), serial: 18) == 29 )

let serial = 7989
let part1 = iterate( 1...298, and: 1...298 ).max { a, b in
  return square(at: a, serial: serial) < square(at: b, serial: serial)
}

print("PART 1", part1 as Any)

// For grid serial number 18, the largest total square (with a total power of
// 113) is 16x16 and has a top-left corner of 90,269, so its identifier is
// 90,269,16.
assert( best(at: (90,269), serial: 18) == (90,269,16,113) )
assert( best(serial: 18) == (90, 269, 16, 113) )

// For grid serial number 42, the largest total square (with a total power of
// 119) is 12x12 and has a top-left corner of 232,251, so its identifier is
// 232,251,12.
assert( best(at: (232,251), serial: 42) == (232,251,12,119) )
assert( best(serial: 42) == (232, 251, 12, 119) )

let part2 = best(serial: serial)
print( "PART 2", part2)