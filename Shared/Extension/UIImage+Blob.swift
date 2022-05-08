import SQLite

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif


extension XImage: Value {
    public class var declaredDatatype: String {
        return Blob.declaredDatatype
    }
    public class func fromDatatypeValue(_ blobValue: Blob) -> XImage {
        return XImage(data: Data.fromDatatypeValue(blobValue))!
    }
    public var datatypeValue: Blob {
#if canImport(UIKit)
        return self.pngData()!.datatypeValue
#elseif canImport(AppKit)
        let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let rep = NSBitmapImageRep(cgImage: cgImage)
        return rep.representation(using: .png, properties: [:])!.datatypeValue
#endif
    }
}
