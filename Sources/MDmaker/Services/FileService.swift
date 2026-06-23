import Foundation

class FileService {
    static let shared = FileService()

    private init() {}

    /// 扫描目录，构建文件树（仅包含 .md 文件和包含 .md 的子文件夹）
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

        for fileURL in contents.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
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
            } else if fileURL.pathExtension.lowercased() == "md" {
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

    /// 读取文件内容
    func loadFile(at url: URL) -> String? {
        try? String(contentsOf: url, encoding: .utf8)
    }

    /// 保存文件内容
    func saveFile(content: String, to url: URL) -> Bool {
        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
            return true
        } catch {
            print("保存失败: \(error.localizedDescription)")
            return false
        }
    }
}
