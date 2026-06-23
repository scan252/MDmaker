import Foundation
import Ink

struct MarkdownParser {
    private let parser = Ink.MarkdownParser()

    func render(_ markdown: String) -> String {
        let html = parser.parse(markdown).html
        return HTMLTemplate.wrap(html)
    }
}
