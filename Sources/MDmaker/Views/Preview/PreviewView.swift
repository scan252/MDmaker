import SwiftUI

struct PreviewView: View {
    @EnvironmentObject var editorState: EditorState

    var body: some View {
        VStack(spacing: 0) {
            // 预览标题栏
            HStack {
                Text("预览")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            Divider()

            // WebView 预览
            if editorState.editorContent.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "eye.slash")
                        .font(.system(size: 28))
                        .foregroundColor(.secondary)
                    Text("暂无内容可预览")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.textBackgroundColor))
            } else {
                WebView(htmlContent: editorState.renderedHTML)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
