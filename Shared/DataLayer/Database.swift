import Foundation
import SQLite

protocol DatabaseProtocol {
    init(fileManager: FileManager, kvStore: UserDefaults) throws
    
    func defineScheme() throws
    func rawQueryPublish(query: String, handler: @escaping (String) -> Void)
    func fetchTables(handler: @escaping ([String]) -> Void) throws
    
    #if DEBUG
    func debugSection()
    #endif
}

let onesDefineKey = "OnesDefineKey"

public final class Database: ObservableObject, DatabaseProtocol {
    private let fileManager: FileManager
    private let kvStore: UserDefaults
    private let db: Connection
    
    public let storeDirectory: URL
    public let dbPosition: URL
    
    public init(fileManager: FileManager = .default, kvStore: UserDefaults = .standard) throws {
        self.fileManager = fileManager
        self.storeDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                                .appendingPathComponent("PrSQLC", isDirectory: true)
        try self.fileManager.createDirectory(at: storeDirectory, withIntermediateDirectories: true)
        self.dbPosition = storeDirectory.appendingPathComponent(SQL.fileName)
        print(dbPosition.absoluteString)
        self.db = try Connection(dbPosition.absoluteString)
        self.kvStore = kvStore
        #if DEBUG
        db.trace { print($0) }
        #endif
    }
    
    public func defineScheme() throws {
        guard !kvStore.bool(forKey: onesDefineKey) else { return }
        try db.execute("PRAGMA foreign_keys=true")
        try db.run(SQL.Create.metaType)
        try db.run(SQL.Create.metaRelation)
        try db.run(SQL.Create.calendar)
        try db.run(SQL.Create.image)
        try db.run(SQL.CreateIndex.metaType)
        try db.run(SQL.CreateIndex.calendar)
        try db.run(SQL.CreateIndex.image)
        kvStore.set(true, forKey: onesDefineKey)
    }
    
    public func rawQueryPublish(
        query: String,
        handler: @escaping (String) -> Void
    ) {
        DispatchQueue.global().async {
            do {
                try self.db.transaction {
                    self.db.anyExecute(query) { handler($0.asView()) }
                }
            } catch {
                handler("\(error)")
            }
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
    ) throws {}
}

#if DEBUG
extension Database {
    func debugSection() {
//        let blob = BlobGen.demoBlob()
//        (0..<1_000_000).forEach { _ in try! self.insertTest(blob) }
//        try! fetchTables { print($0) }
//        try! fetchAll(table: "calendar") { data in
//            dump(data)
//        }
    }
    
    func insertTest(_ blob: Blob) throws {
        let sql1 = SQL.Table.calendar.insert(
            SQL.Expression.title <- "title",
            SQL.Expression.body <- "body \(arc4random())",
            SQL.Expression.memoryAt <- .now
        )
        try db.run(sql1)
        let sql2 = SQL.Table.image.insert(
            SQL.Expression.calendarId <- .random(in: 1...500000),
            SQL.Expression.type <- BlobKind.png.rawValue,
            SQL.Expression.blobData <- blob
        )
        try db.run(sql2)
    }
}

final class MockDatabase: DatabaseProtocol {
    init(fileManager: FileManager = .default, kvStore: UserDefaults = .standard) throws {}
    func defineScheme() throws {}
    func rawQueryPublish(query: String, handler: @escaping (String) -> Void) {}
    func fetchTables(handler: @escaping ([String]) -> Void) throws {}
    func debugSection() {}
}
#endif
