import FootlessParser

public let unsignedInteger = { Int($0)! } <^> oneOrMore(digit)
public let integer = { Int($0)! } <^> (extend <^> char("-") <*> oneOrMore(digit)) <|> unsignedInteger
public let whitespaces = oneOrMore(FootlessParser.whitespace)

extension Dictionary where Key: Equatable {
  public var parser: Parser<Key, Value> {
    return any() >>- { (token: Key) -> Parser<Key,Value> in
      if let value = self[token] {
        return pure(value)
      } else {
        throw ParseError.Mismatch(Remainder([token]), String(describing:self), String(describing: token))
      }
    }
  }
}

extension Dictionary where Key == String {
  public var parser: Parser<Character, Value> {
    return anyOf(keys) >>- { (token: String) -> Parser<Character, Value> in 
      if let value = self[token] {
        return pure(value)
      } else {
        throw ParseError.Mismatch(Remainder(token), String(describing:self), String(describing: token))
      }
    }
  }
}