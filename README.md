# MDmaker

> 一个原生的 macOS Markdown 编辑器，SwiftUI + Ink 构建。

## 当前版本：v0.3.0

### ✅ 已实现功能

- **三栏布局**：侧边栏文件浏览器 + 编辑器 + 实时预览
- **文件夹工作区**：打开文件夹，侧边栏显示 `.md` / `.markdown` 文件树
- **实时预览**：编辑时 300ms 防抖自动渲染，加载文件时立即渲染
- **文件管理**：新建、删除、重命名，右键菜单操作
- **双击打开**：Finder 双击 `.md` / `.markdown` 文件直接在 MDMaker 中打开
- **记忆工作区**：自动恢复上次打开的文件夹
- **未保存保护**：切换文件或退出前提示保存，避免修改丢失
- **Tab 缩进**：编辑器内 Tab 键插入 4 空格，Shift+Tab 回退缩进
- **仅预览模式**：`⌘⌥P` 切换，隐藏编辑器只看预览
- **快捷键**：`⌘O` 打开文件夹、`⌘⇧N` 新建、`⌘S` 保存、`⌘R` 刷新、`⌘\` 切换侧边栏、`⌘⇧P` 切换预览

### ⚠️ 当前版本限制

- **纯文本编辑**：编辑器为纯文本模式，无 Markdown 语法高亮、无行号
- **图片功能未实现**：当前版本仅支持纯文本 Markdown 编辑，不支持粘贴图片、拖拽图片、图片自动落盘等功能。图片相关的 Markdown 语法 `![](path)` 仍可在预览中渲染，但编辑器内不提供图片操作
- **无代码语法高亮**：代码块以等宽字体纯文本显示，无语言着色
- **无同步滚动**：编辑器与预览不联动滚动
- **无全局搜索**：不支持跨文件搜索
- **无导出功能**：不支持导出 PDF / HTML
- **无标签页**：单窗口单文件

### 技术栈

| 层 | 选型 |
|---|---|
| UI | SwiftUI (macOS 14+) |
| Markdown 渲染 | [Ink](https://github.com/JohnSundell/Ink) |
| Web 预览 | WKWebView |
| 打包 | Shell 脚本 + `hdiutil` + `iconutil` + `codesign` |

## 项目结构

```
MDmaker/
├── Package.swift              # Swift Package Manager 配置
├── Info.plist                 # 统一维护的 App 配置
├── Sources/MDmaker/
│   ├── MDmakerApp.swift       # App 入口 + 菜单/快捷键 + onOpenURL
│   ├── Models/
│   │   ├── EditorState.swift  # 核心状态管理
│   │   └── FileItem.swift     # 文件树节点模型
│   ├── Services/
│   │   ├── FileService.swift  # 文件读写 + 目录扫描 + 新建/删除/重命名
│   │   ├── MarkdownParser.swift # Ink 封装
│   │   └── HTMLTemplate.swift # 预览 CSS + 文档包装
│   └── Views/
│       ├── ContentView.swift  # 三栏主布局
│       ├── Editor/EditorView.swift  # NSTextView 编辑器
│       ├── Preview/PreviewView.swift + WebView.swift
│       └── Sidebar/FileBrowserView.swift
├── Scripts/
│   ├── build-app.sh           # 构建 .app bundle
│   ├── generate-icon.swift    # 生成 AppIcon.icns
│   └── package-dmg.sh         # 一键打包 .dmg
└── Package.resolved
```

## 使用方式

### 开发运行

```bash
swift run
```

### 构建 .app

```bash
./Scripts/build-app.sh
open MDmaker.app
```

### 打包 DMG 安装包

```bash
./Scripts/package-dmg.sh
# 产物: MDmaker-<version>.dmg
# 双击打开 -> 拖入 Applications -> 完成安装
```

## 版本历史

**v0.3.0**

- 新增：Finder 双击 `.md` 文件直接打开（onOpenURL）
- 新增：新建 / 删除 / 重命名文件（右键菜单）
- 新增：记忆上次打开的文件夹
- 新增：未保存修改保护（切换文件 / 退出前提示）
- 新增：Tab 缩进 / Shift+Tab 回退
- 新增：仅预览模式（`⌘⌥P`）
- 修复：文件树选中态丢失（FileItem 改用 url 作稳定 id）
- 修复：支持 `.markdown` 扩展名
- 修复：退出时未保存死锁
- 修复：路径前缀误判（`/doc` 不再误匹配 `/docs`）
- 修复：预览空白（WebView 加载时序）
- 重构：渲染链路拆分，JSON 安全注入

**v0.2.0** (2025-06-23)

- 修复：侧边栏文件点击无响应
- 修复：实时预览样式丢失
- 新增：Finder 关联 `.md` 文件
- 修复：DMG 打包脚本

**v0.1.0** - 基础功能完成
