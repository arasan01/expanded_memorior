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
    @Injected var db: any DatabaseProtocol
    
    @Published var query: String = "SELECT * FROM calendar"
    @Published var result: String = "No Output"
    @Published var lastExecute: Date? = nil
    @Published var isQueryOpen = true
    @Published var isOutputOpen = true
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter
    }()
    
    func execute() {
        do {
            try self.db.rawQueryPublish(query: self.query) { output in
                self.result = output
                self.lastExecute = .now
            }
        } catch {
            self.result = error.localizedDescription
            self.lastExecute = .now
        }
    }
    
    func sourceCustomize() -> SourceCodeTextEditor.Customization {
        return .init(
            didChangeText: { _ in },
            insertionPointColor: { Sourceful.Color.white },
            lexerForSource: { _ in SQLiteLexer() },
            textViewDidBeginEditing: { _ in },
            theme: { DefaultSourceCodeTheme() })
    }
    
    func clipboardCopy() {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(self.result, forType: .string)
        #elseif os(iOS)
        UIPasteboard.general.string = self.result
        #endif
    }
}
