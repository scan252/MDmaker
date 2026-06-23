import SwiftUI
import Combine
import Ink

class EditorState: ObservableObject {
    @Published var rootFolderURL: URL?
    @Published var fileTree: [FileItem] = []
    @Published var selectedFileURL: URL?
    @Published var editorContent: String = ""
    @Published var renderedHTML: String = ""
    @Published var showSidebar: Bool = false
    @Published var showPreview: Bool = false
    @Published var isModified: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private let markdownParser = MarkdownParser()

    init() {
        // 监听编辑器内容变化，防抖后渲染预览
        $editorContent
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] content in
                guard let self = self else { return }
                self.renderedHTML = self.markdownParser.render(content)
            }
            .store(in: &cancellables)
    }

    // MARK: - 文件操作

    func openFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.message = "选择包含 Markdown 文件的文件夹"

        if panel.runModal() == .OK, let url = panel.url {
            rootFolderURL = url
            showSidebar = true
            fileTree = FileService.shared.scanDirectory(at: url)
        }
    }

    func selectFile(_ item: FileItem) {
        selectFile(url: item.url)
    }

    func selectFile(url: URL) {
        selectedFileURL = url
        editorContent = FileService.shared.loadFile(at: url) ?? ""
        isModified = false
    }

    func saveFile() {
        guard let url = selectedFileURL else { return }
        if FileService.shared.saveFile(content: editorContent, to: url) {
            isModified = false
        }
    }
}
