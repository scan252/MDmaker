import SwiftUI

struct FileBrowserView: View {
    @EnvironmentObject var editorState: EditorState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 顶部标题栏
            HStack {
                Text(editorState.rootFolderURL?.lastPathComponent ?? "文件")
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
                Spacer()
                Button(action: { editorState.openFolder() }) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 13))
                }
                .buttonStyle(.borderless)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            // 文件树
            if editorState.fileTree.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 28))
                        .foregroundColor(.secondary)
                    Text("未找到 Markdown 文件")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                List(editorState.fileTree, children: \.children) { item in
                    FileRow(item: item,
                            isSelected: editorState.selectedFileURL == item.url,
                            onSelect: { editorState.selectFile(item) })
                }
                .listStyle(.sidebar)
                .font(.system(size: 13))
            }
        }
        .background(Color(.windowBackgroundColor))
    }
}

// MARK: - 单行文件/文件夹

private struct FileRow: View {
    let item: FileItem
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Label(item.name, systemImage: item.isDirectory ? "folder.fill" : "doc.text")
            .foregroundColor(isSelected ? .white : .primary)
            .lineLimit(1)
            .padding(.vertical, 1)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isSelected ? Color.accentColor : Color.clear)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                if !item.isDirectory {
                    onSelect()
                }
            }
    }
}
