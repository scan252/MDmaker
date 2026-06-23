import Foundation

struct FileItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let url: URL
    let isDirectory: Bool
    var children: [FileItem]?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: FileItem, rhs: FileItem) -> Bool {
        lhs.id == rhs.id
    }
}
