//
//  QueryView.swift
//  ProgrammableCalender
//
//  Created by 新山響生 on 2022/05/03.
//

import SwiftUI

let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .medium
    return formatter
}()

struct QueryView: View {
    enum Field: Hashable { case query }
    @EnvironmentObject var db: Database
    @State var query: String = "SELECT * FROM calendar"
    @State var result: String = "No Output"
    @State var lastExecute: Date? = nil
    @FocusState private var focused: Field?
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            VStack {
                HStack {
                    Text("Query")
                    Spacer()
                    Button {
                        db.rawQueryPublish(query: query) { output in
                            result = output
                            lastExecute = .now
                        }
                    } label: {
                        Text("Execute")
                    }.buttonStyle(.bordered)
                }
                TextEditor(text: $query)
                    .background(.clear)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.primary, lineWidth: 2))
                    .frame(minHeight: 100, idealHeight: 300)
                    .focused($focused, equals: .query)
                    .onTapGesture { focused = .query }
            }
            VStack {
                HStack {
                    Text("Output")
                    Button {
                        #if os(macOS)
                        NSPasteboard.general.setString(result, forType: .string)
                        #elseif os(iOS)
                        UIPasteboard.general.string = result
                        #endif
                    } label: {
                        Text("Copy")
                    }
                    .buttonStyle(.bordered)

                    Spacer()
                    if let lastExecute = lastExecute {
                        Text(formatter.string(from: lastExecute))
                    }
                }
                ScrollView {
                    Text(result)
                        .textSelection(.enabled)
                        .lineLimit(nil)
                        .padding(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.primary, lineWidth: 2))
            }
        }
        .padding()
        .onTapGesture { focused = nil }
    }
}

struct QueryView_Previews: PreviewProvider {
    static var previews: some View {
        QueryView()
    }
}
