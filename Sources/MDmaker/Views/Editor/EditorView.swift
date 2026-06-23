import SwiftUI

struct EditorView: View {
    @EnvironmentObject var editorState: EditorState

    var body: some View {
        VStack(spacing: 0) {
            // 顶部工具栏
            HStack(spacing: 12) {
                // 侧边栏切换按钮
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        editorState.showSidebar.toggle()
                    }
                }) {
                    Image(systemName: editorState.showSidebar ? "sidebar.left" : "sidebar.leading")
                        .font(.system(size: 14))
                }
                .buttonStyle(.borderless)

                // 文件名
                if let fileName = editorState.selectedFileURL?.lastPathComponent {
                    Text(fileName)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)

                    if editorState.isModified {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 6, height: 6)
                    }
                } else {
                    Text("未选择文件")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // 预览切换按钮
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        editorState.showPreview.toggle()
                    }
                }) {
                    Image(systemName: editorState.showPreview ? "eye.fill" : "eye")
                        .font(.system(size: 14))
                }
                .buttonStyle(.borderless)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            Divider()

            // 编辑器主体
            if editorState.selectedFileURL != nil {
                TextEditor(text: Binding(
                    get: { editorState.editorContent },
                    set: { newValue in
                        editorState.editorContent = newValue
                        editorState.isModified = true
                    }
                ))
                .font(.system(size: 14, design: .monospaced))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .scrollContentBackground(.hidden)
                .background(Color(.textBackgroundColor))
            } else {
                // 空状态
                VStack(spacing: 16) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.5))

                    Text("打开文件夹开始编辑")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)

                    Button("打开文件夹...") {
                        editorState.openFolder()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.textBackgroundColor))
            }
        }
    }
}
