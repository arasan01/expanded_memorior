import Foundation
import Sourceful

public struct DefaultSourceCodeTheme: SourceCodeTheme {
    
    public init() {
        
    }
    
    private static var lineNumbersColor: Color {
        return Color(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
    }
    
    public let lineNumbersStyle: LineNumbersStyle? = LineNumbersStyle(font: Font(name: "Menlo", size: 16)!, textColor: lineNumbersColor)
    
    public let gutterStyle: GutterStyle = GutterStyle(backgroundColor: Color(red: 21/255.0, green: 22/255, blue: 31/255, alpha: 1.0), minimumWidth: 32)
    
    public let font = Font(name: "Menlo", size: 15)!
    
    public let backgroundColor = Color(red: 31/255.0, green: 32/255, blue: 41/255, alpha: 1.0)
    
    public func color(for syntaxColorType: SourceCodeTokenType) -> Color {
        
        switch syntaxColorType {
        case .plain:
            return .white
            
        case .number:
            return Color(red: 116/255, green: 109/255, blue: 176/255, alpha: 1.0)
            
        case .string:
            return Color(red: 247/255, green: 225/255, blue: 61/255, alpha: 1.0)
            
        case .identifier:
            return Color(red: 255/255, green: 128/255, blue: 128/255, alpha: 1.0)
            
        case .keyword:
            return Color(red: 54/255, green: 174/255, blue: 124/255, alpha: 1.0)
            
        case .comment:
            return Color(red: 169.0/255.0, green: 169.0/255.0, blue: 169.0/255.0, alpha: 1.0)
            
        case .editorPlaceholder:
            return backgroundColor
        }
        
    }
    
}
