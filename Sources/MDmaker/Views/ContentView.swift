import SwiftUI

struct ContentView: View {
    @EnvironmentObject var editorState: EditorState

    var body: some View {
        HStack(spacing: 0) {
            // 左侧栏：文件浏览器
            if editorState.showSidebar {
                FileBrowserView()
                    .frame(width: 220)
                    .transition(.move(edge: .leading))
                Divider()
            }

            // 中间编辑区
            EditorView()
                .frame(maxWidth: .infinity)

            // 右侧栏：实时预览
            if editorState.showPreview {
                Divider()
                PreviewView()
                    .frame(maxWidth: .infinity)
                    .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: editorState.showSidebar)
        .animation(.easeInOut(duration: 0.25), value: editorState.showPreview)
    }
}
