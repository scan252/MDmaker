import SwiftUI

struct PreviewView: View {
    @EnvironmentObject var editorState: EditorState

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("预览").font(.system(size: 13, weight: .medium)).foregroundColor(.secondary)
                Spacer()
                if editorState.previewOnlyMode {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.25)) { editorState.previewOnlyMode = false }
                    }) {
                        Image(systemName: "rectangle.split.2x1").font(.system(size: 14))
                    }
                    .buttonStyle(.borderless)
                    .help("退出仅预览模式 (⌘⌥P)")
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 8)
            Divider()
            if editorState.editorContent.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "eye.slash").font(.system(size: 28)).foregroundColor(.secondary)
                    Text("暂无内容可预览").font(.system(size: 12)).foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.textBackgroundColor))
            } else {
                WebView(htmlBody: editorState.renderedHTML, css: HTMLTemplate.css, baseURL: editorState.selectedFileURL?.deletingLastPathComponent())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
