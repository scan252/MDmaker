import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    let htmlContent: String

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.setValue(false, forKey: "drawsBackground")
        webView.loadHTMLString(htmlContent, baseURL: nil)
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        // 从完整 HTML 中提取 body 内容，保留 head 里的 CSS
        let bodyContent = extractBodyContent(from: htmlContent)
        let escapedContent = bodyContent
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "`", with: "\\`")
            .replacingOccurrences(of: "$", with: "\\$")
        let js = "document.body.innerHTML = `\(escapedContent)`;"
        nsView.evaluateJavaScript(js) { _, _ in }
    }

    /// 从完整 HTML 字符串中提取 <body>...</body> 之间的内容
    private func extractBodyContent(from html: String) -> String {
        guard let bodyStart = html.range(of: "<body>"),
              let bodyEnd = html.range(of: "</body>") else {
            return html
        }
        return String(html[bodyStart.upperBound..<bodyEnd.lowerBound])
    }
}
