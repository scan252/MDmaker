import SwiftUI
import AppKit

struct EditorView: View {
    @EnvironmentObject var editorState: EditorState

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) { editorState.showSidebar.toggle() }
                }) {
                    Image(systemName: editorState.showSidebar ? "sidebar.left" : "sidebar.leading")
                        .font(.system(size: 14))
                }
                .buttonStyle(.borderless)
                .help("切换侧边栏 (⌘\\)")

                if editorState.rootFolderURL != nil || editorState.selectedFileURL != nil {
                    Button(action: { editorState.createFile() }) {
                        Image(systemName: "doc.badge.plus").font(.system(size: 14))
                    }
                    .buttonStyle(.borderless)
                    .help("新建文件 (⌘⇧N)")
                }

                if let fileName = editorState.selectedFileURL?.lastPathComponent {
                    Text(fileName).font(.system(size: 13, weight: .medium)).foregroundColor(.primary).lineLimit(1)
                    if editorState.isModified {
                        Circle().fill(Color.orange).frame(width: 6, height: 6).help("有未保存的修改")
                    }
                } else {
                    Text("未选择文件").font(.system(size: 13)).foregroundColor(.secondary)
                }

                Spacer()

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) { editorState.showPreview.toggle() }
                }) {
                    Image(systemName: editorState.showPreview ? "eye.fill" : "eye").font(.system(size: 14))
                }
                .buttonStyle(.borderless)
                .help("切换预览 (⌘⇧P)")

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        editorState.previewOnlyMode.toggle()
                        if editorState.previewOnlyMode && !editorState.showPreview { editorState.showPreview = true }
                    }
                }) {
                    Image(systemName: editorState.previewOnlyMode ? "rectangle.expand.vertical" : "rectangle.split.2x1").font(.system(size: 14))
                }
                .buttonStyle(.borderless)
                .help("仅预览模式 (⌘⌥P)")
            }
            .padding(.horizontal, 16).padding(.vertical, 8)
            Divider()

            if editorState.selectedFileURL != nil {
                MarkdownTextEditor(text: Binding(
                    get: { editorState.editorContent },
                    set: { newValue in
                        if newValue != editorState.editorContent { editorState.editorContent = newValue; editorState.isModified = true }
                    }
                ))
                .font(.system(size: 14, design: .monospaced))
                .padding(.horizontal, 20).padding(.vertical, 12)
                .background(Color(.textBackgroundColor))
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text").font(.system(size: 48)).foregroundColor(.secondary.opacity(0.5))
                    Text("打开文件夹开始编辑").font(.system(size: 15)).foregroundColor(.secondary)
                    HStack(spacing: 12) {
                        Button("打开文件夹...") { editorState.openFolder() }.buttonStyle(.bordered).controlSize(.large)
                        if editorState.rootFolderURL != nil {
                            Button("新建文件") { editorState.createFile() }.buttonStyle(.bordered).controlSize(.large)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.textBackgroundColor))
            }
        }
    }
}

struct MarkdownTextEditor: NSViewRepresentable {
    @Binding var text: String

    func makeNSView(context: Context) -> NSScrollView {
        let textView = TabInsertingTextView(frame: .zero)
        let scrollView = NSScrollView()
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.scrollerStyle = .overlay
        configure(textView: textView, context: context)
        return scrollView
    }

    private func configure(textView: NSTextView, context: Context) {
        textView.delegate = context.coordinator
        textView.font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.allowsUndo = true
        textView.usesAdaptiveColorMappingForDarkAppearance = true
        textView.isRichText = false
        textView.string = text
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        if textView.string != text {
            let selectedRange = textView.selectedRange()
            textView.string = text
            if selectedRange.location <= text.count { textView.setSelectedRange(selectedRange) }
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MarkdownTextEditor
        init(parent: MarkdownTextEditor) { self.parent = parent }
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
        }
    }
}

final class TabInsertingTextView: NSTextView {
    private let tabIndent = "    "

    override func insertTab(_ sender: Any?) {
        insertText(tabIndent, replacementRange: selectedRange())
    }

    override func insertBacktab(_ sender: Any?) {
        let range = selectedRange()
        let lineStart = (string as NSString).lineRange(for: NSRange(location: range.location, length: 0))
        let lineStartLoc = lineStart.location
        let deleteCount = min(4, range.location - lineStartLoc)
        if deleteCount > 0 {
            let deleteRange = NSRange(location: range.location - deleteCount, length: deleteCount)
            let segment = (string as NSString).substring(with: deleteRange)
            if segment.allSatisfy({ $0 == " " }) {
                insertText("", replacementRange: deleteRange)
                return
            }
        }
        super.insertBacktab(sender)
    }
}
