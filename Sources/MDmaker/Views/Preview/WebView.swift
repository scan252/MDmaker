import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    let htmlBody: String
    let css: String
    let baseURL: URL?

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.underPageBackgroundColor = .clear
        webView.navigationDelegate = context.coordinator
        let fullHTML = HTMLTemplate.document(withBody: htmlBody, css: css)
        webView.loadHTMLString(fullHTML, baseURL: baseURL)
        context.coordinator.loadedBaseURL = baseURL
        context.coordinator.pendingBody = htmlBody
        context.coordinator.isFirstLoad = true
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        if context.coordinator.loadedBaseURL != baseURL {
            let fullHTML = HTMLTemplate.document(withBody: htmlBody, css: css)
            nsView.loadHTMLString(fullHTML, baseURL: baseURL)
            context.coordinator.loadedBaseURL = baseURL
            context.coordinator.pendingBody = htmlBody
            context.coordinator.isFirstLoad = true
            return
        }
        if context.coordinator.pendingBody == htmlBody { return }
        if context.coordinator.isFirstLoad {
            context.coordinator.pendingBody = htmlBody
            return
        }
        context.coordinator.pendingBody = htmlBody
        injectBody(into: nsView)
    }

    private func injectBody(into webView: WKWebView) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: [htmlBody], options: []),
              let jsonString = String(data: jsonData, encoding: .utf8) else { return }
        let js = """
        (function() {
            try { document.body.innerHTML = (\(jsonString))[0]; }
            catch(e) { console.error('预览渲染失败', e); }
        })();
        """
        webView.evaluateJavaScript(js) { _, _ in }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var loadedBaseURL: URL?
        var pendingBody: String = ""
        var isFirstLoad = true

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if isFirstLoad {
                isFirstLoad = false
                if !pendingBody.isEmpty {
                    let js = """
                    (function() {
                        try { document.body.innerHTML = (\(Self.jsonEncode(pendingBody))); }
                        catch(e) { console.error('预览渲染失败', e); }
                    })();
                    """
                    webView.evaluateJavaScript(js) { _, _ in }
                }
            }
        }

        private static func jsonEncode(_ string: String) -> String {
            guard let data = try? JSONSerialization.data(withJSONObject: [string], options: []),
                  let result = String(data: data, encoding: .utf8) else { return "[\"\"]" }
            return result
        }
    }
}
