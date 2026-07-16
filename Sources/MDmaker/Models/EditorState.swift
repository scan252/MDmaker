import SwiftUI
import Combine
import Ink

class EditorState: ObservableObject {
    @Published var rootFolderURL: URL? {
        didSet {
            if let url = rootFolderURL {
                UserDefaults.standard.set(url.path, forKey: Self.lastFolderKey)
            }
        }
    }
    @Published var fileTree: [FileItem] = []
    @Published var selectedFileURL: URL?
    @Published var editorContent: String = ""
    @Published var renderedHTML: String = ""
    @Published var isModified: Bool = false
    @Published var showSidebar: Bool = false
    @Published var showPreview: Bool = true
    @Published var previewOnlyMode: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var showSaveBeforeSwitchAlert: Bool = false
    private var pendingSelectURL: URL?
    var pendingSwitchIsClose: Bool {
        pendingSelectURL == nil && showSaveBeforeSwitchAlert
    }
    private var cancellables = Set<AnyCancellable>()
    private let markdownParser = MarkdownParser()
    private static let lastFolderKey = "lastRootFolderURL"

    init() {
        $editorContent
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] content in
                guard let self = self else { return }
                self.renderedHTML = self.markdownParser.renderBody(content)
            }
            .store(in: &cancellables)
        if let path = UserDefaults.standard.string(forKey: Self.lastFolderKey) {
            let url = URL(fileURLWithPath: path)
            if FileManager.default.fileExists(atPath: path) {
                rootFolderURL = url
                showSidebar = true
                fileTree = FileService.shared.scanDirectory(at: url)
            } else {
                UserDefaults.standard.removeObject(forKey: Self.lastFolderKey)
            }
        }
    }

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

    func refreshFileTree() {
        if let url = rootFolderURL {
            fileTree = FileService.shared.scanDirectory(at: url)
            return
        }
        if let fileURL = selectedFileURL {
            let dir = fileURL.deletingLastPathComponent()
            rootFolderURL = dir
            showSidebar = true
            fileTree = FileService.shared.scanDirectory(at: dir)
        }
    }

    func selectFile(_ item: FileItem) {
        selectFile(url: item.url)
    }

    func selectFile(url: URL, force: Bool = false) {
        if selectedFileURL == url { return }
        if isModified && !force {
            pendingSelectURL = url
            showSaveBeforeSwitchAlert = true
            return
        }
        loadFile(url: url)
    }

    private func loadFile(url: URL) {
        selectedFileURL = url
        do {
            editorContent = try FileService.shared.loadFile(at: url)
            isModified = false
            renderedHTML = markdownParser.renderBody(editorContent)
        } catch {
            showError(message: error.localizedDescription)
        }
    }

    func openExternalFile(_ url: URL) {
        if isModified {
            pendingSelectURL = url
            showSaveBeforeSwitchAlert = true
            return
        }
        if let root = rootFolderURL,
           url.path.hasPrefix(root.path + "/") || url.path == root.path {
            loadFile(url: url)
        } else {
            let dir = url.deletingLastPathComponent()
            rootFolderURL = dir
            showSidebar = true
            fileTree = FileService.shared.scanDirectory(at: dir)
            selectedFileURL = url
            do {
                editorContent = try FileService.shared.loadFile(at: url)
                isModified = false
                renderedHTML = markdownParser.renderBody(editorContent)
            } catch {
                showError(message: error.localizedDescription)
            }
        }
    }

    func saveFile() {
        guard let url = selectedFileURL else { return }
        do {
            try FileService.shared.saveFile(content: editorContent, to: url)
            isModified = false
        } catch {
            showError(message: error.localizedDescription)
        }
    }

    func createFile(in directory: URL? = nil) {
        let root: URL
        if let dir = directory {
            root = dir
        } else if let r = rootFolderURL {
            root = r
        } else if let fileURL = selectedFileURL {
            root = fileURL.deletingLastPathComponent()
            rootFolderURL = root
            showSidebar = true
            fileTree = FileService.shared.scanDirectory(at: root)
        } else {
            showError(message: "请先打开一个文件夹，再新建文件。")
            return
        }
        var name = "未命名.md"
        var counter = 1
        while FileManager.default.fileExists(atPath: root.appendingPathComponent(name).path) {
            name = "未命名 \(counter).md"
            counter += 1
        }
        do {
            let url = try FileService.shared.createFile(in: root, named: name)
            refreshFileTree()
            loadFile(url: url)
        } catch {
            showError(message: error.localizedDescription)
        }
    }

    func deleteFile(_ item: FileItem) {
        do {
            try FileService.shared.deleteFile(at: item.url)
            if selectedFileURL == item.url {
                selectedFileURL = nil
                editorContent = ""
                renderedHTML = ""
                isModified = false
            }
            refreshFileTree()
        } catch {
            showError(message: error.localizedDescription)
        }
    }

    func renameFile(_ item: FileItem, to newName: String) {
        do {
            let newURL = try FileService.shared.renameFile(at: item.url, to: newName)
            if selectedFileURL == item.url {
                selectedFileURL = newURL
            }
            refreshFileTree()
        } catch {
            showError(message: error.localizedDescription)
        }
    }

    func confirmSaveAndSwitch() {
        saveFile()
        showSaveBeforeSwitchAlert = false
        if let url = pendingSelectURL {
            loadFile(url: url)
            pendingSelectURL = nil
        }
    }

    func confirmDiscardAndSwitch() {
        isModified = false
        showSaveBeforeSwitchAlert = false
        if let url = pendingSelectURL {
            loadFile(url: url)
            pendingSelectURL = nil
        }
    }

    func cancelSwitch() {
        pendingSelectURL = nil
        showSaveBeforeSwitchAlert = false
    }

    func handleUnsavedBeforeClose() -> Bool {
        if isModified {
            showSaveBeforeSwitchAlert = true
            pendingSelectURL = nil
            return false
        }
        return true
    }

    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}
