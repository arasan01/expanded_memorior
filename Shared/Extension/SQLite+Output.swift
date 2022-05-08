import SQLite
import Foundation

extension Array where Element == Binding? {
    func get(_ index: Int) -> SQLiteType {
        switch self[index] {
        case let blob as Blob:
            return .blob(blob)
        case let real as Double:
            return .real(real)
        case let integer as Int64:
            return .integer(integer)
        case let text as String:
            return .text(text)
        case .some(_):
            return .unknown
        case .none:
            return .null
        }
    }
}
