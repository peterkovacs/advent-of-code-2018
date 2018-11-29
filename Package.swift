// swift-tools-version:4.2
import PackageDescription

let package = Package( name: "AdventOfCode2018",
                       products: [
                         .library(name: "AdventOfCode", targets: [ "AdventOfCode" ]),
                         .executable(name: "Day1", targets: [ "Day1" ])
                       ],
                       dependencies: [
                        .package( url: "https://github.com/peterkovacs/FootlessParser.git", .branch( "inout-remainder" ) ),
                       ],
                       targets: [
                         .target( name: "AdventOfCode", dependencies: [ "FootlessParser" ] ),
                         .target( name: "Day1", dependencies: [ "AdventOfCode" ] )
                       ]
                      )
