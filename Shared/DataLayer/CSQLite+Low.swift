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
                    let values = UnsafeMutableBufferPointer<UnsafeMutablePointer<Int8>?>(
                        start: raw_values,
                        count: Int(count))
                    let names = UnsafeMutableBufferPointer<UnsafeMutablePointer<Int8>?>(
                        start: raw_names,
                        count: Int(count))
                    
                    var row = [String: String]()
                    
                    for i in 0 ..< Int(count) {
                        let raw_value = values[i].unsafelyUnwrapped
                        let value = String(
                            bytesNoCopy: raw_value,
                            length: strlen(raw_value),
                            encoding: .utf8,
                            freeWhenDone: false).unsafelyUnwrapped
                        
                        let raw_name = names[i].unsafelyUnwrapped
                        let name = String(
                            bytesNoCopy: raw_name,
                            length: strlen(raw_name),
                            encoding: .utf8,
                            freeWhenDone: false).unsafelyUnwrapped
                        
                        row[name] = value
                    }
                    
                    let context_ptr = context.unsafelyUnwrapped.assumingMemoryBound(
                        to: (([String: String]) -> Void).self)
                    context_ptr.pointee(row)
                    
                    return SQLITE_OK
                },
                context_ptr,
                &errmsg)
            let model = SQLAnyExecuteModel(
                status: result == SQLITE_OK
                ? .ok
                : .error(String(bytesNoCopy: errmsg.unsafelyUnwrapped,
                                length: strlen(errmsg.unsafelyUnwrapped),
                                encoding: .utf8,
                                freeWhenDone: true).unsafelyUnwrapped),
                output: logBuffer)
            handler(model)
        }
    }
}

