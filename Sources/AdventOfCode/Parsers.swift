import FootlessParser

public let unsignedInteger = { Int($0)! } <^> oneOrMore(digit)
public let integer = { Int($0)! } <^> (extend <^> char("-") <*> oneOrMore(digit)) <|> unsignedInteger
public let whitespaces = oneOrMore(FootlessParser.whitespace)