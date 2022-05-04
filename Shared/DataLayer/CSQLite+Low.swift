import Foundation
import SQLite
import SQLite3

struct SQLAnyExecuteModel {
    enum Status {
        case ok
        case error(String)
    }
    
    let status: Status
    let output: [[String: String]]
    
    func asView() -> String {
        let outputStr = String(
            data: try! JSONSerialization.data(
                withJSONObject: output,
                options: [
                    .prettyPrinted,
                    .withoutEscapingSlashes,
                    .sortedKeys,
                    .fragmentsAllowed]),
            encoding: .utf8)!
        switch status {
        case .ok:
            return "Successed\n\n\(outputStr)"
        case .error(let string):
            return "\(string)\n\n\(outputStr)"
        }
    }
}

extension SQLite.Connection {
    
    func anyExecute(
        _ SQL: String,
        handler: @escaping (SQLAnyExecuteModel) -> Void
    ) {
        DispatchQueue.global().async {
            var result: Int32 = 0
            var errmsg: UnsafeMutablePointer<Int8>?
            var logBuffer: [[String: String]] = []
            let context_ptr = UnsafeMutablePointer<((_ row: [String: String]) -> Void)?>
                .allocate(capacity: 1)
            context_ptr.initialize(to: { row in
                logBuffer.append(row)
            })
            defer {
                context_ptr.deinitialize(count: 1)
                context_ptr.deallocate()
            }
            result = sqlite3_exec(
                self.handle,
                SQL,
                { (context:  UnsafeMutableRawPointer?,
                   count: Int32,
                   raw_values: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?,
                   raw_names:  UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?
                ) -> Int32 in
                    var row = [String: String]()
                    for i in 0 ..< Int(count) {
                        if let raw_value = raw_values?[i],
                           let raw_name = raw_names?[i] {
                            let value = String(cString: raw_value)
                            let name = String(cString: raw_name)
                            row[name] = value
                        }
                    }
                    if let context_ptr = context?.assumingMemoryBound(
                        to: (([String: String]) -> Void).self) {
                        context_ptr.pointee(row)
                    }
                    return SQLITE_OK
                },
                context_ptr,
                &errmsg)
            let model = SQLAnyExecuteModel(
                status: result == SQLITE_OK
                ? .ok
                : .error(errmsg.map { String(cString: $0) } ?? ""),
                output: logBuffer)
            handler(model)
        }
    }
}

