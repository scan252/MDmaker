import SwiftUI

@main
struct MDmakerApp: App {
    @StateObject private var editorState = EditorState()
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(editorState)
                .frame(minWidth: 800, minHeight: 600)
                .onOpenURL { url in
                    editorState.openExternalFile(url)
                }
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 1000, height: 700)
        .commands {
            CommandGroup(after: .newItem) {
                Button("打开文件夹...") { editorState.openFolder() }
                .keyboardShortcut("o", modifiers: .command)
                Button("新建文件") { editorState.createFile() }
                .keyboardShortcut("n", modifiers: [.command, .shift])
                .disabled(editorState.rootFolderURL == nil && editorState.selectedFileURL == nil)
                Button("保存") { editorState.saveFile() }
                .keyboardShortcut("s", modifiers: .command)
                .disabled(editorState.selectedFileURL == nil || !editorState.isModified)
                Divider()
                Button("刷新文件树") { editorState.refreshFileTree() }
                .keyboardShortcut("r", modifiers: .command)
                .disabled(editorState.rootFolderURL == nil && editorState.selectedFileURL == nil)
            }
            CommandMenu("视图") {
                Button("切换侧边栏") {
                    withAnimation(.easeInOut(duration: 0.25)) { editorState.showSidebar.toggle() }
                }
                .keyboardShortcut("\\", modifiers: .command)
                Button("切换预览") {
                    withAnimation(.easeInOut(duration: 0.25)) { editorState.showPreview.toggle() }
                }
                .keyboardShortcut("p", modifiers: [.command, .shift])
                Divider()
                Button("仅预览模式") {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        editorState.previewOnlyMode.toggle()
                        if editorState.previewOnlyMode && !editorState.showPreview { editorState.showPreview = true }
                    }
                }
                .keyboardShortcut("p", modifiers: [.command, .option])
            }
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    static var sharedEditorState: EditorState?

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard let state = AppDelegate.sharedEditorState ?? Self.sharedEditorState else { return .terminateNow }
        if !state.isModified { return .terminateNow }
        guard NSApp.windows.contains(where: { $0.contentView != nil }) else { return .terminateNow }
        _ = state.handleUnsavedBeforeClose()
        return .terminateLater
    }
}

extension Notification.Name {
    static let checkUnsavedBeforeQuit = Notification.Name("checkUnsavedBeforeQuit")
}
