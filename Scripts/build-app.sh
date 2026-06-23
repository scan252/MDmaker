#!/bin/bash
set -e

cd "$(dirname "$0")/.."

echo "🔨 正在编译..."
swift build

# ── 生成图标 ──
echo "🎨 正在生成图标..."
swift Scripts/generate-icon.swift
iconutil -c icns MDmaker.app/Contents/Resources/AppIcon.iconset \
    -o MDmaker.app/Contents/Resources/AppIcon.icns

APP_DIR="MDmaker.app/Contents"
mkdir -p "$APP_DIR/MacOS"
mkdir -p "$APP_DIR/Resources"

cp .build/debug/MDmaker "$APP_DIR/MacOS/MDmaker"

cat > "$APP_DIR/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>MDmaker</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.mdmaker.app</string>
    <key>CFBundleName</key>
    <string>MDmaker</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>0.2.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>com.apple.security.app-sandbox</key>
    <false/>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
    <key>CFBundleDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeName</key>
            <string>Markdown File</string>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>LSHandlerRank</key>
            <string>Default</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>net.daringfireball.markdown</string>
            </array>
        </dict>
    </array>
    <key>UTImportedTypeDeclarations</key>
    <array>
        <dict>
            <key>UTTypeIdentifier</key>
            <string>net.daringfireball.markdown</string>
            <key>UTTypeTagSpecification</key>
            <dict>
                <key>public.filename-extension</key>
                <array>
                    <string>md</string>
                    <string>markdown</string>
                </array>
            </dict>
        </dict>
    </array>
</dict>
</plist>
EOF

echo "✅ MDmaker.app 构建完成！"
echo "运行: open MDmaker.app"
