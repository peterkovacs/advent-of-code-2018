import CoreGraphics
import Foundation

public struct Pixel {
  public var a: UInt8
  public var b: UInt8
  public var g: UInt8
  public var r: UInt8
}

public extension CGRect {
  public var area: CGFloat {
    return width * height
  }
}

public extension CGContext {
  public subscript(x x: Int, y y: Int) -> Pixel? {
    let bytesPerPixel = bytesPerRow / width
    return data?.advanced(by: bytesPerPixel * ((width * y) + x)).assumingMemoryBound(to: Pixel.self).pointee
  }
}