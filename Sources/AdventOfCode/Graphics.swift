import CoreGraphics
import Foundation

public struct Pixel {
  public var a: UInt8
  public var r: UInt8
  public var g: UInt8
  public var b: UInt8

  public init(a: UInt8, r: UInt8, g: UInt8, b: UInt8) {
    self.a = a
    self.r = r
    self.g = g
    self.b = b
  }
}

public extension CGRect {
  public var area: CGFloat {
    return width * height
  }
}

public extension CGContext {
  public static func square(size: Int) -> CGContext {
    let context = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue )!
    context.translateBy(x: 0, y: CGFloat(size))
    context.scaleBy(x: 1, y: -1)
    return context
  }
  public subscript(x x: Int, y y: Int) -> Pixel {
    get {
      let stride = bytesPerRow / MemoryLayout<Pixel>.size
      return data!.assumingMemoryBound(to: Pixel.self).advanced(by: stride * y + x ).pointee
    }
    set {
      let stride = bytesPerRow / MemoryLayout<Pixel>.size
      data!.assumingMemoryBound(to: Pixel.self).advanced(by: stride * y + x ).pointee = newValue
    }
  }

  public subscript(x x: CGFloat, y y: CGFloat) -> Pixel {
    return self[x: Int(x.rounded()), y: Int(y.rounded())]
  }

  public subscript(rect: CGRect) -> [Pixel] {
    var result: [Pixel] = []
    for y in stride(from: rect.minY, to: rect.maxY, by: 1) {
      for x in stride(from: rect.minX, to: rect.maxX, by: 1) {
        result.append(self[x: x, y: y])
      }
    }
    return result
  }

  @discardableResult func save(to destinationURL: URL) -> Bool { 
    guard let destination = CGImageDestinationCreateWithURL(destinationURL as CFURL, kUTTypePNG, 1, nil) else { return false } 
    CGImageDestinationAddImage(destination, self.makeImage()!, nil) 
    return CGImageDestinationFinalize(destination) 
  }

}