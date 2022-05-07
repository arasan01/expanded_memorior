import Foundation
import SQLite

protocol DatabaseProtocol {
    init(fileManager: FileManager) throws
    
    func defineScheme() throws
    func rawQueryPublish(query: String, handler: @escaping (String) -> Void) throws
    func fetchTables(handler: @escaping ([String]) -> Void) throws
    func insertTest() throws
    
    #if DEBUG
    func debugSection()
    #endif
}

public final class Database: ObservableObject, DatabaseProtocol {
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
    ) throws {
        try db.transaction {
            self.db.anyExecute(query) { handler($0.asView()) }
        }
    }
    
    public func fetchTables(
        handler: @escaping ([String]) -> Void
    ) throws {
        let tables = Array(try db.prepare(SQL.Table.sqliteMaster))
            .map { $0[SQL.Expression.tableName] }
        handler(tables)
    }
    
    public func fetchAll(
        table: String,
        handler: @escaping ( [[String:String?]] ) -> Void
    ) throws {
        for row in try db.prepare(SQL.Table.anyTable(table).limit(10)) {
            let v: [String: String?] = try row.decode()
            print(v)
        }
//        handler(decoded)
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

#if DEBUG
extension Database {
    func debugSection() {
//        (0..<5).forEach { _ in try! self.insertTest() }
//        try! fetchTables { print($0) }
        try! fetchAll(table: "calendar") { data in
            dump(data)
        }
    }
}

final class MockDatabase: DatabaseProtocol {
    init(fileManager: FileManager = .default) throws {}
    func defineScheme() throws {}
    func rawQueryPublish(query: String, handler: @escaping (String) -> Void) throws {}
    func fetchTables(handler: @escaping ([String]) -> Void) throws {}
    func insertTest() throws {}
    func debugSection() {}
}
#endif
