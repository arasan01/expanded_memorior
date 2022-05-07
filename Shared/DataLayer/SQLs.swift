import Foundation
import SQLite

enum SQL {
    static let fileName = "PrSQLC.sqlite"
    
    enum Command {
        static let schema = ".schema"
    }
    
    enum Table {
        static let calendar = SQLite.Table("calendar")
        static let image = SQLite.Table("image")
        static let sqliteMaster = SQLite.Table("sqlite_master")
        static func anyTable(_ literal: String) -> SQLite.Table {
            return SQLite.Table(literal)
        }
    }
    
    enum Expression {
        static let calendarId = SQLite.Expression<Int64>("calendar_id")
        static let title = SQLite.Expression<String>("title")
        static let body = SQLite.Expression<String>("body")
        static let memoryAt = SQLite.Expression<Date>("memory_at")
        static let imageData = SQLite.Expression<Blob>("imageData")
        static let type = SQLite.Expression<String>("type")
        static let tableName = SQLite.Expression<String>("tbl_name")
        static let sql = SQLite.Expression<String>("sql")
        static func anyKey<T: SQLite.ExpressionType>(_ literal: String) -> SQLite.Expression<T> {
            return SQLite.Expression<T>(literal)
        }
    }
    
    enum Create {
        static let calendar: String = {
            return SQL.Table.calendar.create(ifNotExists: true) { t in
                t.column(SQL.Expression.calendarId, primaryKey: .autoincrement)
                t.column(SQL.Expression.title)
                t.column(SQL.Expression.body)
                t.column(SQL.Expression.memoryAt)
            }
        }()
        
        static let image: String = {
            return SQL.Table.image.create(ifNotExists: true) { t in
                t.column(
                    SQL.Expression.calendarId,
                    references: SQL.Table.calendar, SQL.Expression.calendarId)
                t.column(SQL.Expression.type)
                t.column(SQL.Expression.imageData)
            }
        }()
    }
}
