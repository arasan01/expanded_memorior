import Foundation
import SQLite

enum BlobGen {
    static func demoBlob() -> Blob {
        let context = CGContext(
            data: nil,
            width: 32,
            height: 32,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo:
                CGBitmapInfo.byteOrder32Little.rawValue |
            CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        context.setAllowsAntialiasing(false)
        context.interpolationQuality = .none
        
        context.setFillColor(XColor.white.cgColor)
        context.fill(CGRect(
            x: 0, y: 0, width: 32, height: 32))
        
        context.setStrokeColor(XColor.red.cgColor)
        context.move(to: CGPoint(x: 0, y: 0))
        context.addLine(to: CGPoint(x: 32, y: 32))
        context.setLineWidth(2)
        context.strokePath()
        
        guard let image = context.makeImage()?.pngRepresentation() else {
            fatalError("blob not generated")
        }
        return image.datatypeValue
    }

}
