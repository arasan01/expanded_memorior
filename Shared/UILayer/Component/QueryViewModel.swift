//
//  QueryViewModel.swift
//  ProgrammableCalender
//
//  Created by 新山響生 on 2022/05/07.
//

import SwiftUI
import Combine
import Sourceful
import Resolver

final class QueryViewModel: ObservableObject {
    @ObservedObject var code: CodeViewModel
    @ObservedObject var output: QueryOutputViewModel
    
    init(code: CodeViewModel, output: QueryOutputViewModel) {
        self.code = code
        self.output = output
        self.code.setup(
            result: self.$output.result,
            lastExecute: self.$output.lastExecute)
    }
}

final class CodeViewModel: ObservableObject {
    @Injected var db: any DatabaseProtocol
    @Published var query: String = "SELECT * FROM calendar"
    @Published var isQueryOpen = true
    var result: Binding<String>!
    var lastExecute: Binding<Date?>!
    
    func setup(result: Binding<String>, lastExecute: Binding<Date?>) {
        self.result = result
        self.lastExecute = lastExecute
    }
    
    func sourceCustomize() -> SourceCodeTextEditor.Customization {
        return .init(
            didChangeText: { _ in },
            insertionPointColor: { Sourceful.Color.white },
            lexerForSource: { _ in SQLiteLexer() },
            textViewDidBeginEditing: { _ in },
            theme: { DefaultSourceCodeTheme() })
    }
    
    func execute() {
        self.result.wrappedValue = "Query executing ..."
        self.db.rawQueryPublish(query: self.query) { output in
            DispatchQueue.main.async {
                self.result.wrappedValue = output
                self.lastExecute.wrappedValue = .now
            }
        }
    }
}

final class QueryOutputViewModel: ObservableObject {
    @Injected var db: any DatabaseProtocol
    @Published var result: String = "No Output"
    @Published var lastExecute: Date? = nil
    @Published var isOutputOpen = true
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter
    }()
    
    func clipboardCopy() {
#if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(self.result, forType: .string)
#elseif os(iOS)
        UIPasteboard.general.string = self.result
#endif
    }
}
