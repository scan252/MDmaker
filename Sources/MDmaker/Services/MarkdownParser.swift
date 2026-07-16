import Foundation
import Ink

struct MarkdownParser {
    private let parser = Ink.MarkdownParser()

    /// 仅返回 body 部分的 HTML（不含 <html><head>），完整文档由 WebView/HTMLTemplate 负责包装
    func renderBody(_ markdown: String) -> String {
        parser.parse(markdown).html
    }
}
