import Foundation

struct FileItem: Identifiable, Hashable {
    /// 用 url.path 作为稳定 id，避免每次扫描目录后选中态/展开态丢失
    let id: String
    let name: String
    let url: URL
    let isDirectory: Bool
    var children: [FileItem]?

    init(name: String, url: URL, isDirectory: Bool, children: [FileItem]?) {
        self.id = url.path
        self.name = name
        self.url = url
        self.isDirectory = isDirectory
        self.children = children
    }
}
