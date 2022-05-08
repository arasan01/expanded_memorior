import Foundation
import SQLite
import SQLite3

private extension TimeInterval {
    var view: String { String(format: "%.3f", self * 1000) }
}

struct SQLAnyExecuteModel {
    enum Status {
        case ok
        case error(String)
    }
    
    let status: Status
    let output: [LogModel]
    let executeTime: TimeInterval
    
    func asView() -> String {
        switch status {
        case .ok:
            return "Successed - time: \(executeTime.view)ms\n\n\(output.map(\.description).joined(separator: "\n"))"
        case .error(let error):
            return "\(error)"
        }
    }
}

struct LogModel {
    let sql: String
    let columnNames: [String]
    let rows: [[SQLiteType]]
    let changed: Int
    
    var count: Int {
        rows.count
    }
    
    subscript(index: Int) -> [SQLiteType] {
        return rows[index]
    }
    
    subscript(column: String) -> [SQLiteType] {
        guard let colIdx = columnNames.firstIndex(of: column) else {
            fatalError("Miss of column name")
        }
        return rows.map { $0[colIdx] }
    }
    
    subscript(index: Int, column: String) -> SQLiteType {
        guard let colIdx = columnNames.firstIndex(of: column) else {
            fatalError("Miss of column name")
        }
        return rows[index][colIdx]
    }
    
    var description: String {
        return """
        --------------------------------------
        \(sql)
        
        """ + (changed == 0
        ? """
        \(columnNames.joined(separator: ","))
        \(rows.map({
            $0.map(\.valueDescription).joined(separator: ",")
        }).joined(separator: "\n"))
        """
        : """
        DB Changed: \(changed)
        """)
    }
}

extension SQLite.Connection {
    
    func anyExecute(
        _ multilineSql: String,
        handler: @escaping (SQLAnyExecuteModel) -> Void
    ) {
        let startDate = Date.now
        let sqls =  multilineSql
            .components(separatedBy: ";")
            .map{ $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter({ !$0.isEmpty})
        let logBuffer: [LogModel]
        do {
        logBuffer = try sqls.map { sql in
            let stmt = try prepare(sql)
            var chunk: [[SQLiteType]] = []
            for row in stmt {
                let log = (0..<stmt.columnCount).map(row.get(_:))
                chunk.append(log)
            }
            return LogModel(
                sql: sql,
                columnNames: stmt.columnNames,
                rows: chunk,
                changed: stmt.columnCount != 0 ? 0 : self.changes)
        }
        } catch let error {
            let model = SQLAnyExecuteModel(
                status: .error("\(error)"),
                output: [],
                executeTime: Date.now.timeIntervalSince(startDate))
            handler(model)
            return
        }
        
        let model = SQLAnyExecuteModel(
            status: .ok,
            output: logBuffer,
            executeTime: Date.now.timeIntervalSince(startDate))
        handler(model)
    }
}

