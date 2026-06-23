import Foundation

struct HTMLTemplate {
    static func wrap(_ body: String) -> String {
        """
        <!DOCTYPE html>
        <html lang="zh-CN">
        <head>
            <meta charset="utf-8">
            <style>
                * {
                    margin: 0;
                    padding: 0;
                    box-sizing: border-box;
                }

                body {
                    font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Helvetica Neue", sans-serif;
                    font-size: 15px;
                    line-height: 1.7;
                    color: #1d1d1f;
                    padding: 32px 40px;
                    max-width: 760px;
                    margin: 0 auto;
                    background-color: #ffffff;
                }

                @media (prefers-color-scheme: dark) {
                    body {
                        color: #f5f5f7;
                        background-color: #1e1e1e;
                    }
                    h1, h2, h3, h4, h5, h6 { color: #f5f5f7; }
                    a { color: #64d2ff; }
                    code { background-color: #2c2c2e; color: #ff6961; }
                    pre { background-color: #2c2c2e; }
                    pre code { color: #f5f5f7; }
                    blockquote { border-left-color: #48484a; color: #98989d; }
                    hr { border-color: #38383a; }
                    table th, table td { border-color: #38383a; }
                    table th { background-color: #2c2c2e; }
                    table tr:nth-child(even) { background-color: #2c2c2e; }
                }

                h1, h2, h3, h4, h5, h6 {
                    color: #1d1d1f;
                    font-weight: 600;
                    margin-top: 1.5em;
                    margin-bottom: 0.5em;
                    line-height: 1.3;
                }

                h1 { font-size: 2em; margin-top: 0; }
                h2 { font-size: 1.5em; }
                h3 { font-size: 1.25em; }
                h4 { font-size: 1.1em; }

                p {
                    margin-bottom: 1em;
                }

                a {
                    color: #0066cc;
                    text-decoration: none;
                }

                a:hover {
                    text-decoration: underline;
                }

                code {
                    font-family: "SF Mono", "Menlo", "Monaco", monospace;
                    font-size: 0.88em;
                    background-color: #f5f5f7;
                    color: #e53935;
                    padding: 2px 6px;
                    border-radius: 4px;
                }

                pre {
                    background-color: #f5f5f7;
                    border-radius: 8px;
                    padding: 16px 20px;
                    margin: 1em 0;
                    overflow-x: auto;
                }

                pre code {
                    background: none;
                    color: #1d1d1f;
                    padding: 0;
                    font-size: 0.88em;
                    line-height: 1.6;
                }

                blockquote {
                    border-left: 3px solid #d2d2d7;
                    color: #6e6e73;
                    padding-left: 16px;
                    margin: 1em 0;
                }

                ul, ol {
                    padding-left: 1.5em;
                    margin-bottom: 1em;
                }

                li {
                    margin-bottom: 0.3em;
                }

                hr {
                    border: none;
                    border-top: 1px solid #d2d2d7;
                    margin: 2em 0;
                }

                img {
                    max-width: 100%;
                    border-radius: 8px;
                }

                table {
                    border-collapse: collapse;
                    width: 100%;
                    margin: 1em 0;
                }

                table th, table td {
                    border: 1px solid #d2d2d7;
                    padding: 8px 12px;
                    text-align: left;
                }

                table th {
                    background-color: #f5f5f7;
                    font-weight: 600;
                }

                table tr:nth-child(even) {
                    background-color: #fafafa;
                }
            </style>
        </head>
        <body>
        \(body)
        </body>
        </html>
        """
    }
}
