import AdventOfCode
import Foundation
import FootlessParser

func part1() {
  var b = 0, c = 0, d = 0, f = 0

  f = c | 0x10000
  c = 0x4fdfac
  while true {
    d = f & 0xff
    c = d + c
    c = c & 0xffffff
    c = c * 65899
    c = c & 0xffffff

    if 256 > f {
      print("PART 1", c)
      return
    }

    d = 0
    while true {
      b = d + 1
      b = 256 * b
      if b > f {
        break
      }
      d = d + 1
    }
    f = d
  }
}

func part2() {
  var b = 0, c = 0, d = 0, f = 0
  var results = Set<Int>()
  var last = 0

  while true {
    f = c | 0x10000
    c = 0x4fdfac
    while true {
      d = f & 0xff
      c = d + c
      c = c & 0xffffff
      c = c * 65899
      c = c & 0xffffff

      if 256 > f {
        let (inserted, _) = results.insert(c)
        if inserted {
          last = c
        } else {
          print("PART 2", last)
          return
        }
        break
      }

      d = 0
      while true {
        b = d + 1
        b = 256 * b
        if b > f {
          break
        }
        d = d + 1
      }
      f = d
    }
  }
}

part1()
part2()