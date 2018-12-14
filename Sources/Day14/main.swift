import Foundation

var data = [3,7]
data.reserveCapacity(20*1024*1024)
var (elf1, elf2) = (0, 1)

struct RecipeGenerator: Sequence, IteratorProtocol {
  var pos = 0

  mutating func next() -> Int? {
    defer { pos += 1 }
    if pos == data.count {
      let sum = data[elf1] + data[elf2]
      if sum > 9 {
        data.append(1)
      }
      data.append(sum % 10)
      elf1 = ( elf1 + data[elf1] + 1 ) % (data.count)
      elf2 = ( elf2 + data[elf2] + 1 ) % (data.count)
    }

    return data[pos]
  }

  mutating func last(n: Int) -> String {
    if data.count < n {
      return dropFirst(n - pos).prefix(10).map(String.init).joined(separator: "")
    } else {
      pos = n
      return prefix(10).map(String.init).joined(separator: "")
    }
  }

  mutating func find(elements: [Int]) -> Int {
    for i in 0... {
      pos = Swift.min( data.count - 1, i )
      if dropFirst(i - pos).prefix(elements.count).elementsEqual(elements) {
        return i
      }
    }

    return -1
  }
}

var recipes = RecipeGenerator()
assert( recipes.last(n: 5) == "0124515891", String(describing: recipes) )
assert( recipes.last(n: 9) == "5158916779", String(describing: recipes) )
assert( recipes.last(n: 18) == "9251071085", String(describing: recipes) )
assert( recipes.last(n: 2018) == "5941429882")
print( "PART 1", recipes.last(n: 554401) )
print( "PART 2", recipes.find(elements: [5, 5, 4, 4, 0, 1]) )
