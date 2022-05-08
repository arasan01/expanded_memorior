import Foundation

#if canImport(UIKit)
import UIKit
public typealias XImage = UIImage
public typealias XColor = UIColor
#elseif canImport(AppKit)
import AppKit
public typealias XImage = NSImage
public typealias XColor = NSColor
#endif
