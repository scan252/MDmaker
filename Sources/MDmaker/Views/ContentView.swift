import SwiftUI
import AppKit

struct ContentView: View {
    @EnvironmentObject var editorState: EditorState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HStack(spacing: 0) {
            if editorState.showSidebar {
                FileBrowserView().frame(width: 220).transition(.move(edge: .leading))
                Divider()
            }
            if editorState.previewOnlyMode {
                PreviewView().frame(maxWidth: .infinity).transition(.opacity)
            } else {
                EditorView().frame(maxWidth: .infinity)
                if editorState.showPreview {
                    Divider()
                    PreviewView().frame(width: 420).transition(.move(edge: .trailing))
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: editorState.showSidebar)
        .animation(.easeInOut(duration: 0.25), value: editorState.showPreview)
        .animation(.easeInOut(duration: 0.25), value: editorState.previewOnlyMode)
        .onAppear { AppDelegate.sharedEditorState = editorState }
        .alert("有未保存的修改", isPresented: $editorState.showSaveBeforeSwitchAlert) {
            Button("保存") {
                if editorState.pendingSwitchIsClose {
                    editorState.confirmSaveAndSwitch()
                    NSApp.reply(toApplicationShouldTerminate: true)
                } else { editorState.confirmSaveAndSwitch() }
            }
            Button("不保存") {
                if editorState.pendingSwitchIsClose {
                    editorState.confirmDiscardAndSwitch()
                    NSApp.reply(toApplicationShouldTerminate: true)
                } else { editorState.confirmDiscardAndSwitch() }
            }
            Button("取消", role: .cancel) {
                if editorState.pendingSwitchIsClose {
                    editorState.cancelSwitch()
                    NSApp.reply(toApplicationShouldTerminate: false)
                } else { editorState.cancelSwitch() }
            }
        } message: { Text("是否保存当前文件的修改？") }
        .alert("出错了", isPresented: $editorState.showError) {
            Button("好", role: .cancel) {}
        } message: { Text(editorState.errorMessage ?? "未知错误") }
    }
}
