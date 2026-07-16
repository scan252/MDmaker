import SwiftUI
import AppKit

struct FileBrowserView: View {
    @EnvironmentObject var editorState: EditorState
    @State private var renamingItem: FileItem?
    @State private var newName: String = ""
    @State private var deleteConfirmation: FileItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(editorState.rootFolderURL?.lastPathComponent ?? "文件")
                    .font(.system(size: 13, weight: .semibold)).lineLimit(1)
                Spacer()
                Button(action: { editorState.createFile() }) {
                    Image(systemName: "doc.badge.plus").font(.system(size: 13))
                }
                .buttonStyle(.borderless).help("新建文件 (⌘⇧N)")
                Button(action: { editorState.refreshFileTree() }) {
                    Image(systemName: "arrow.clockwise").font(.system(size: 13))
                }
                .buttonStyle(.borderless).help("刷新文件树 (⌘R)")
                Button(action: { editorState.openFolder() }) {
                    Image(systemName: "folder.badge.plus").font(.system(size: 13))
                }
                .buttonStyle(.borderless).help("打开文件夹")
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            Divider()
            if editorState.fileTree.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "doc.text").font(.system(size: 28)).foregroundColor(.secondary)
                    Text("未找到 Markdown 文件").font(.system(size: 12)).foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity).padding()
            } else {
                List(editorState.fileTree, children: \.children) { item in
                    FileRow(item: item, isSelected: editorState.selectedFileURL == item.url, onSelect: { editorState.selectFile(item) })
                        .contextMenu {
                            if item.isDirectory {
                                Button("在此新建文件") { editorState.createFile(in: item.url) }
                            } else {
                                Button("重命名") { renamingItem = item; newName = item.name }
                                Divider()
                                Button("删除", role: .destructive) { deleteConfirmation = item }
                            }
                        }
                }
                .listStyle(.sidebar).font(.system(size: 13))
            }
        }
        .background(Color(.windowBackgroundColor))
        .alert("确认删除？", isPresented: Binding(get: { deleteConfirmation != nil }, set: { if !$0 { deleteConfirmation = nil } })) {
            Button("删除", role: .destructive) { if let item = deleteConfirmation { editorState.deleteFile(item) }; deleteConfirmation = nil }
            Button("取消", role: .cancel) { deleteConfirmation = nil }
        } message: { Text("确定要删除「\(deleteConfirmation?.name ?? "")」吗？此操作不可撤销。") }
        .sheet(isPresented: Binding(get: { renamingItem != nil }, set: { if !$0 { renamingItem = nil } })) {
            RenameSheet(name: $newName) { finalName in
                if let item = renamingItem, !finalName.isEmpty { editorState.renameFile(item, to: finalName) }
                renamingItem = nil
            }
        }
    }
}

private struct FileRow: View {
    let item: FileItem
    let isSelected: Bool
    let onSelect: () -> Void
    var body: some View {
        Label(item.name, systemImage: item.isDirectory ? "folder.fill" : "doc.text")
            .foregroundColor(isSelected ? .white : .primary).lineLimit(1)
            .padding(.vertical, 1).padding(.horizontal, 4)
            .background(RoundedRectangle(cornerRadius: 4).fill(isSelected ? Color.accentColor : Color.clear))
            .contentShape(Rectangle())
            .onTapGesture { if !item.isDirectory { onSelect() } }
    }
}

private struct RenameSheet: View {
    @Binding var name: String
    let onConfirm: (String) -> Void
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack(spacing: 16) {
            Text("重命名文件").font(.headline)
            TextField("文件名", text: $name).textFieldStyle(.roundedBorder).onSubmit { confirm() }
            HStack {
                Button("取消") { dismiss() }.keyboardShortcut(.cancelAction)
                Spacer()
                Button("确定") { confirm() }.keyboardShortcut(.defaultAction)
            }
        }
        .padding(20).frame(width: 320)
    }
    private func confirm() { onConfirm(name); dismiss() }
}
