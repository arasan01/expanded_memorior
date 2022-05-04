import Foundation
import SQLite

public final class Database: ObservableObject {
    private let fileManager: FileManager
    private let db: Connection
    
    public let storeDirectory: URL
    public let dbPosition: URL
    
    public init(fileManager: FileManager = .default) throws {
        self.fileManager = fileManager
        self.storeDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                                .appendingPathComponent("PrSQLC", isDirectory: true)
        try self.fileManager.createDirectory(at: storeDirectory, withIntermediateDirectories: true)
        self.dbPosition = storeDirectory.appendingPathComponent(SQL.fileName)
        print(dbPosition.absoluteString)
        self.db = try Connection(dbPosition.absoluteString)
    }
    
    public func defineScheme() throws {
        try db.run(SQL.Create.calendar)
        try db.run(SQL.Create.image)
    }
    
    public func rawQueryPublish(
        query: String,
        handler: @escaping (String) -> Void
    ) {
        db.anyExecute(query, handler: { handler($0.asView()) })
    }
    
    public func insertTest() throws {
        let sql = SQL.Table.calendar.insert(
            SQL.Expression.title <- "title",
            SQL.Expression.body <- "body \(arc4random())",
            SQL.Expression.memoryAt <- .now
        )
        print(sql.asSQL())
        try db.run(sql)
    }
}
