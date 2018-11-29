// swift-tools-version:4.2
import PackageDescription

let package = Package( name: "AdventOfCode2018",
                       products: [
                         .library(name: "AdventOfCode", targets: [ "AdventOfCode" ]),
                         .executable(name: "Day1", targets: [ "Day1" ])
                       ],
                       dependencies: [
                        .package( url: "https://github.com/IBM-Swift/CommonCrypto.git", from: "1.0.0" ),
                        .package( url: "https://github.com/peterkovacs/FootlessParser.git", .branch( "inout-remainder" ) ),
                       ],
                       targets: [
                         .target( name: "AdventOfCode", dependencies: [ "CommonCrypto", "FootlessParser" ] ),
                         .target( name: "Day1", dependencies: [ "AdventOfCode" ] )
                       ]
                       )
