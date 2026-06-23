import SwiftUI

@main
struct MDmakerApp: App {
    @StateObject private var editorState = EditorState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(editorState)
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 1000, height: 700)
        .commands {
            CommandGroup(after: .newItem) {
                Button("打开文件夹...") {
                    editorState.openFolder()
                }
                .keyboardShortcut("o", modifiers: .command)

                Button("保存") {
                    editorState.saveFile()
                }
                .keyboardShortcut("s", modifiers: .command)
                .disabled(editorState.selectedFileURL == nil || !editorState.isModified)
            }

            CommandMenu("视图") {
                Button("切换侧边栏") {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        editorState.showSidebar.toggle()
                    }
                }
                .keyboardShortcut("b", modifiers: .command)

                Button("切换预览") {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        editorState.showPreview.toggle()
                    }
                }
                .keyboardShortcut("p", modifiers: .command)
            }
        }
    }
}
