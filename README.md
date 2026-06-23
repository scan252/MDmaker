# MDmaker

> 一个原生的 macOS Markdown 编辑器，SwiftUI + Ink 构建。

## 功能

- **三栏布局**：侧边栏文件浏览器 + 编辑器 + 实时预览
- **文件夹工作区**：打开一个文件夹，侧边栏显示 `.md` 文件树
- **实时预览**：编辑时 300ms 防抖自动渲染，支持 Markdown → HTML
- **快捷键**：`⌘O` 打开文件夹、`⌘S` 保存、`⌘B` 切换侧边栏、`⌘P` 切换预览
- **独立应用**：打包为标准 `.app` / `.dmg`，拖入 `/Applications` 即用
- **文件关联**：支持 `.md` / `.markdown` 文件类型关联，Finder 右键打开

## 技术栈

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
├── Sources/MDmaker/
│   ├── MDmakerApp.swift       # App 入口 + 菜单/快捷键
│   ├── Models/
│   │   ├── EditorState.swift  # 核心状态管理 (ObservableObject)
│   │   └── FileItem.swift     # 文件树节点模型
│   ├── Services/
│   │   ├── FileService.swift  # 文件读写 + 目录扫描
│   │   ├── MarkdownParser.swift # Ink 封装
│   │   └── HTMLTemplate.swift # 预览 HTML 模板
│   └── Views/
│       ├── ContentView.swift  # 三栏主布局
│       ├── Editor/EditorView.swift
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
# 产物: MDmaker-0.2.0.dmg
# 双击打开 → 拖入 Applications → 完成安装
```

## 版本

**v0.2.0** (2025-06-23)

- 修复：侧边栏文件点击无响应（重写 FileBrowserView 选择机制）
- 修复：实时预览更新后样式丢失（WebView JS 改为仅更新 body）
- 新增：`CFBundleDocumentTypes` + `UTImportedTypeDeclarations`，支持 Finder 关联 `.md` 文件
- 修复：DMG 打包脚本挂载/卸载逻辑，避免僵尸挂载

**v0.1.0** — 基础功能完成，可独立运行的 Markdown 编辑器。

## 归档日期

2025-06-24
