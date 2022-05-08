import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension CGImage {
    func pngRepresentation() -> Data? {
#if canImport(UIKit)
        return self.map(UIImage.init(cgImage:)).pngData()
#elseif canImport(AppKit)
        let rep = NSBitmapImageRep(cgImage: self)
        return rep.representation(using: .png, properties: [:])!
#endif
    }
}
