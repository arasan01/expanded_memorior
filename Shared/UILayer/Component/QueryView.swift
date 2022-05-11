import SwiftUI
import Sourceful
import Resolver

struct QueryView: View {
    enum Field: Hashable { case query }
    
    @StateObject var model: QueryViewModel
    @FocusState private var focused: Field?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            CodeView(model: model.code, focused: _focused)
            OutputView(model: model.output, focused: _focused)
            Spacer()
        }
        .frame(alignment: .top)
        .padding()
        .onTapGesture { focused = nil }
        .animation(.easeIn(duration: 0.25), value: model.code.isQueryOpen)
        .animation(.easeIn(duration: 0.25), value: model.output.isOutputOpen)
    }
}

private struct OpenableModifier: ViewModifier {
    let key: KeyEquivalent
    func body(content: Content) -> some View {
        content
            .buttonStyle(.borderless)
            .foregroundColor(.primary)
            .keyboardShortcut(key, modifiers: .control)
            .help("Open and Close the section (⌃ \(String(key.character)))")
    }
}

private struct ExecutableModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.return, modifiers: [.command])
            .help("Execute the query (⌘ ↵)")
    }
}

private struct CopiableModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .buttonStyle(.bordered)
            .keyboardShortcut("c", modifiers: [.command, .shift])
            .help("Copy the output logged (⇧ ⌘ C)")
    }
}

private struct OutputBorder: ViewModifier {
    func body(content: Content) -> some View {
        #if os(macOS)
        return content
        #elseif os(iOS)
        return content
            .padding(3)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.primary, lineWidth: 2))
        #endif
    }
}

private struct CodeView: View {
    @ObservedObject var model: CodeViewModel
    @FocusState var focused: QueryView.Field?
    
    var body: some View {
        print("code redraw")
        return VStack {
            HStack {
                Button {
                    model.isQueryOpen.toggle()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: model.isQueryOpen
                              ? "chevron.down" : "chevron.forward")
                            .frame(width: 20, height: 20)
                        Text("Query")
                    }
                    Spacer()
                }
                .modifier(OpenableModifier(key: "1"))
                Button {
                    model.execute()
                } label: {
                    Text("Execute")
                }
                .modifier(ExecutableModifier())
            }
            if model.isQueryOpen {
                SourceCodeTextEditor(
                    text: $model.query,
                    customization: model.sourceCustomize(),
                    shouldBecomeFirstResponder: false
                )
                .frame(minHeight: 100)
                .focused($focused, equals: .query)
                .onTapGesture { focused = .query }
            }
        }
    }
}

private struct OutputView: View {
    @ObservedObject var model: QueryOutputViewModel
    @FocusState var focused: QueryView.Field?
    
    var body: some View {
        print("output redraw")
        return VStack {
            HStack {
                Button {
                    model.isOutputOpen.toggle()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: model.isOutputOpen
                              ? "chevron.down" : "chevron.forward")
                            .frame(width: 20, height: 20)
                        Text("Output")
                    }
                    if let lastExecute = model.lastExecute {
                        Text(model.formatter.string(from: lastExecute))
                    }
                    Spacer()
                }
                .modifier(OpenableModifier(key: "2"))
                Button {
                    model.clipboardCopy()
                } label: {
                    Text("Copy")
                }
                .modifier(CopiableModifier())
                
            }
            if model.isOutputOpen {
                TextEditor(text: .constant(model.result))
                    .modifier(OutputBorder())
            }
        }
    }
}

struct QueryView_Previews: PreviewProvider {
    static var previews: some View {
        Resolver.registerMockServices()
        return QueryView(model: Resolver.resolve())
    }
}
