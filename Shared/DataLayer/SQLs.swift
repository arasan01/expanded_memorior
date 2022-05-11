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
        static let metaType = SQLite.Table("meta_type")
        static let metaRelation = SQLite.Table("meta_relation")
        static func anyTable(_ literal: String) -> SQLite.Table {
            return SQLite.Table(literal)
        }
    }
    
    enum Expression {
        static let calendarId = SQLite.Expression<Int64>("calendar_id")
        static let title = SQLite.Expression<String>("title")
        static let body = SQLite.Expression<String>("body")
        static let memoryAt = SQLite.Expression<Date>("memory_at")
        static let blobData = SQLite.Expression<Blob>(BlobKindKey.blob.rawValue)
        static let type = SQLite.Expression<String>(BlobKindKey.type.rawValue)
        static let tableName = SQLite.Expression<String>("tbl_name")
        static let columnName = SQLite.Expression<String>("col_name")
        static let swiftType = SQLite.Expression<String>("swift_type")
        static let relationTable = SQLite.Expression<String>("rel_tbl")
        static let relationColumn = SQLite.Expression<String>("rel_col")
        static let sql = SQLite.Expression<String>("sql")
        static func anyKey<T: SQLite.ExpressionType>(_ literal: String) -> SQLite.Expression<T> {
            return SQLite.Expression<T>(literal)
        }
    }
    
    enum Create {
        static let metaType: String = {
            return SQL.Table.metaType.create(ifNotExists: true) { t in
                t.column(SQL.Expression.tableName)
                t.column(SQL.Expression.columnName)
                t.column(SQL.Expression.swiftType)
            }
        }()
        
        static let metaRelation: String = {
            return SQL.Table.metaRelation.create(ifNotExists: true) { t in
                t.column(SQL.Expression.tableName)
                t.column(SQL.Expression.columnName)
                t.column(SQL.Expression.relationTable)
                t.column(SQL.Expression.relationColumn)
            }
        }()
        
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
                t.column(SQL.Expression.blobData)
            }
        }()
    }
    
    enum CreateIndex {
        static let metaType: String = {
            return SQL.Table.metaType.createIndex(SQL.Expression.tableName, ifNotExists: true)
        }()
        
        static let calendar: String = {
            return SQL.Table.calendar.createIndex(SQL.Expression.calendarId, ifNotExists: true)
        }()
        
        static let image: String = {
            return SQL.Table.image.createIndex(SQL.Expression.calendarId, ifNotExists: true)
        }()
    }
}
