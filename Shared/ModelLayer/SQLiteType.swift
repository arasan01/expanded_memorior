import Foundation
import SQLite

enum SQLiteType {
    case integer(Int64)
    case real(Double)
    case text(String)
    case blob(Blob)
    case null
    case unknown
    
    var valueDescription: String {
        switch self {
        case .integer(let v):
            return "\(v)"
        case .real(let v):
            return "\(v)"
        case .text(let v):
            return "\(v)"
        case .blob(let v):
            return "\(v.toHex().prefix(32))..."
        case .null:
            return "NULL"
        case .unknown:
            return "panic"
        }
    }
    
    var setDescription: String {
        switch self {
        case .integer(let v):
            return "INTEGER: \(v)"
        case .real(let v):
            return "REAL: \(v)"
        case .text(let v):
            return "TEXT: \(v)"
        case .blob(let v):
            return "BLOB: \(v.toHex())"
        case .null:
            return "NULL"
        case .unknown:
            return "panic"
        }
    }
    
    var boolValue: Bool? {
        switch self {
        case .integer(let v):
            return Bool.fromDatatypeValue(v)
        default:
            return nil
        }
    }
    
    var intValue: Int? {
        switch self {
        case .integer(let v):
            return Int.fromDatatypeValue(v)
        default:
            return nil
        }
    }
}

extension SQLiteType: CustomDebugStringConvertible {
    var debugDescription: String {
        return setDescription
    }
}
