import Foundation
import FootlessParser
import AdventOfCode

typealias LabeledPoint = (label: Int, x: Int, y: Int)

func distance( from: (Int, Int), to: LabeledPoint ) -> Int {
  return abs(from.0 - to.x) + abs(from.1 - to.y)
}

func best( point: (Int, Int) ) -> (label: Int, distance: Int)? {
    let best = input.reduce( into: (label: 0, distance: Int.max, points: Set<Int>()) ) { best, k in
      let dist = distance(from: point, to: k)

      if dist == best.distance {
        best.points.insert(k.label)
      }
      else if dist < best.distance {
        best = ( label: k.label, distance: dist, points: Set([k.label]) )
      }
    }
    if best.points.count > 1 { return nil }
    return ( best.label, best.distance )
}

func color(label: Int) -> Pixel {
  return Pixel(a: 255,
               r: UInt8(label), 
               g: UInt8((label + 50) * ((label + 1) % 3)),
               b: UInt8((label + 50) * ((label + 2) % 3)))
}

func determineInfiniteColors(maxX: Int, maxY: Int) -> Set<UInt8> {
  let colors = (0...maxX).reduce(into: Set<UInt8>()) { s, x in
    if let b = best(point: (x, 0)) {
      s.insert(UInt8(b.label))
    }
    if let b = best(point: (x, maxY)) {
      s.insert(UInt8(b.label))
    }
  } 

  return (0...maxY).reduce(into: colors) { s, y in
    if let b = best(point: (0, y)) {
      s.insert(UInt8(b.label))
    }
    if let b = best(point: (maxX, y)) {
      s.insert(UInt8(b.label))
    }
  }
}

func parse() -> [LabeledPoint] {
  let parser = tuple <^> integer <*> (char(",") *> whitespace *> integer)
  return stdin.enumerated().map { 
    let value = try! FootlessParser.parse( parser, $0.element ) 
    return (label: $0.offset, x: value.0, y: value.1)
  }
}

let input = parse()
let maxX = input.max(by: { $0.x < $1.x })!.x
let maxY = input.max(by: { $0.y < $1.y })!.y
let infiniteColors = determineInfiniteColors(maxX: maxX, maxY: maxY)

let context = iterate(0...maxX, and: 0...maxY).reduce(into: CGContext.square( size: max( maxX, maxY ) )) { context, point in 
  if let closest = best(point: point) {
    context[point] = color(label: closest.label)
    if closest.distance < 1 {
      context[point].g = 255
    }

    if infiniteColors.contains(UInt8(closest.label)) {
      context[point].a = 0
    }
  }
}

var counts: [UInt8: Int] = context.filter { $0.a > 0 }.reduce(into: [:]) { counts, pixel in
  if !infiniteColors.contains(pixel.r) {
    counts[pixel.r, default: 0] += 1
  }
}

let part1 = counts.max { $0.value < $1.value }!
print( "PART 1", part1.value )

func sumOfDistances(from: (Int, Int)) -> Int {
  return input.reduce(0) { $0 + abs(from.0 - $1.x) + abs(from.1 - $1.y) }
}

var part2 = iterate(0...maxX, and: 0...maxY).reduce(0) { $0 + (sumOfDistances(from: $1) < 10000 ? 1 : 0) }
print( "PART 2", part2)

context.save(to: URL(fileURLWithPath: "image.png"))