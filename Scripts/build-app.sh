#!/bin/bash
set -e
cd "$(dirname "$0")/.."
APP_DIR="MDmaker.app/Contents"
echo "🔨 正在编译..."
swift build
echo "📁 正在构建 .app bundle..."
mkdir -p "$APP_DIR/MacOS"
mkdir -p "$APP_DIR/Resources"
cp .build/debug/MDmaker "$APP_DIR/MacOS/MDmaker"
cp Info.plist "$APP_DIR/Info.plist"
echo "🎨 正在生成图标..."
swift Scripts/generate-icon.swift "$APP_DIR/Resources/AppIcon.iconset"
iconutil -c icns "$APP_DIR/Resources/AppIcon.iconset" -o "$APP_DIR/Resources/AppIcon.icns"
rm -rf "$APP_DIR/Resources/AppIcon.iconset"
echo "✅ MDmaker.app 构建完成！"
echo "运行: open MDmaker.app"
