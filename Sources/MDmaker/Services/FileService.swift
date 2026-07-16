import Foundation

enum FileServiceError: LocalizedError {
    case readFailed(URL, Error)
    case writeFailed(URL, Error)
    case createFailed(URL, Error)
    case deleteFailed(URL, Error)
    case renameFailed(URL, Error)

    var errorDescription: String? {
        switch self {
        case .readFailed(let url, let err):
            return "读取「\(url.lastPathComponent)」失败：\(err.localizedDescription)"
        case .writeFailed(let url, let err):
            return "保存「\(url.lastPathComponent)」失败：\(err.localizedDescription)"
        case .createFailed(let url, _):
            return "创建文件「\(url.lastPathComponent)」失败，可能已存在同名文件。"
        case .deleteFailed(let url, _):
            return "删除「\(url.lastPathComponent)」失败。"
        case .renameFailed(let url, _):
            return "重命名「\(url.lastPathComponent)」失败。"
        }
    }
}

class FileService {
    static let shared = FileService()

    private init() {}

    /// 支持的 Markdown 扩展名
    static let supportedExtensions: Set<String> = ["md", "markdown"]

    /// 判断 URL 是否为 Markdown 文件
    static func isMarkdownFile(_ url: URL) -> Bool {
        supportedExtensions.contains(url.pathExtension.lowercased())
    }

    /// 扫描目录，构建文件树（仅包含 .md/.markdown 文件和包含它们的子文件夹）
    func scanDirectory(at url: URL) -> [FileItem] {
        let fm = FileManager.default
        guard let contents = try? fm.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        var items: [FileItem] = []

        for fileURL in contents.sorted(by: { $0.lastPathComponent.lowercased() < $1.lastPathComponent.lowercased() }) {
            let isDir = (try? fileURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false

            if isDir {
                let children = scanDirectory(at: fileURL)
                if !children.isEmpty {
                    items.append(FileItem(
                        name: fileURL.lastPathComponent,
                        url: fileURL,
                        isDirectory: true,
                        children: children
                    ))
                }
            } else if FileService.isMarkdownFile(fileURL) {
                items.append(FileItem(
                    name: fileURL.lastPathComponent,
                    url: fileURL,
                    isDirectory: false,
                    children: nil
                ))
            }
        }

        return items
    }

    /// 读取文件内容，失败时抛错
    func loadFile(at url: URL) throws -> String {
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            throw FileServiceError.readFailed(url, error)
        }
    }

    /// 保存文件内容，失败时抛错
    func saveFile(content: String, to url: URL) throws {
        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            throw FileServiceError.writeFailed(url, error)
        }
    }

    /// 新建 Markdown 文件，返回新建文件的 URL
    func createFile(in directory: URL, named fileName: String) throws -> URL {
        var name = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty { name = "未命名" }
        if !FileService.isMarkdownFile(URL(fileURLWithPath: name)) {
            name += ".md"
        }
        let fileURL = directory.appendingPathComponent(name)
        do {
            try "".write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            throw FileServiceError.createFailed(fileURL, error)
        }
    }

    /// 删除文件
    func deleteFile(at url: URL) throws {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            throw FileServiceError.deleteFailed(url, error)
        }
    }

    /// 重命名文件，返回新 URL
    func renameFile(at url: URL, to newName: String) throws -> URL {
        var name = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty { name = "未命名" }
        if !FileService.isMarkdownFile(URL(fileURLWithPath: name)) {
            name += ".md"
        }
        let newURL = url.deletingLastPathComponent().appendingPathComponent(name)
        guard newURL != url else { return url }
        if FileManager.default.fileExists(atPath: newURL.path) {
            throw FileServiceError.renameFailed(url, NSError(domain: "MDmaker", code: 1, userInfo: [NSLocalizedDescriptionKey: "已存在同名文件「\(name)」"]))
        }
        do {
            try FileManager.default.moveItem(at: url, to: newURL)
            return newURL
        } catch {
            throw FileServiceError.renameFailed(url, error)
        }
    }
}
