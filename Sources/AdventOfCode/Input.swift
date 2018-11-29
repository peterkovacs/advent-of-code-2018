import Foundation

public let stdin = sequence( state: (), next: { _ in readLine( strippingNewline: true ) } )
