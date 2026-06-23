#!/bin/bash
set -e

cd "$(dirname "$0")/.."

PROJECT_DIR="$(pwd)"
APP_NAME="MDmaker"
VERSION="0.2.0"
BUILD_DIR="$PROJECT_DIR/.build/dmg"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
DMG_NAME="$APP_NAME-$VERSION.dmg"
DMG_PATH="$PROJECT_DIR/$DMG_NAME"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📦 打包 $APP_NAME v$VERSION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ──────────────────────────────────
# Step 1: 编译 release 版本
# ──────────────────────────────────
echo ""
echo "🔨 [1/5] 编译 release 版本..."
swift build -c release

# ──────────────────────────────────
# Step 2: 构建 .app bundle
# ──────────────────────────────────
echo ""
echo "📁 [2/5] 构建 .app bundle..."

rm -rf "$BUILD_DIR"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# 复制二进制
cp "$PROJECT_DIR/.build/release/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

# 生成图标
swift "$PROJECT_DIR/Scripts/generate-icon.swift" "$APP_BUNDLE/Contents/Resources/AppIcon.iconset" 2>/dev/null
iconutil -c icns "$APP_BUNDLE/Contents/Resources/AppIcon.iconset" \
    -o "$APP_BUNDLE/Contents/Resources/AppIcon.icns" 2>/dev/null

# Info.plist
cat > "$APP_BUNDLE/Contents/Info.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.mdmaker.app</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
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
PLIST

echo "  ✓ $APP_BUNDLE"

# ──────────────────────────────────
# Step 3: 临时签名（避免 Gatekeeper 直接拦截）
# ──────────────────────────────────
echo ""
echo "🔐 [3/5] 临时签名..."
codesign --force --deep --sign - "$APP_BUNDLE" 2>/dev/null && echo "  ✓ 已 ad-hoc 签名" || echo "  ⚠️ 签名跳过（不影响本地使用）"

# ──────────────────────────────────
# Step 4: 创建 DMG
# ──────────────────────────────────
echo ""
echo "💿 [4/5] 创建 DMG..."

rm -f "$DMG_PATH"

# 清理可能残留的挂载
hdiutil detach "/Volumes/$APP_NAME" -quiet -force 2>/dev/null || true
for i in 1 2 3 4 5; do
    hdiutil detach "/Volumes/$APP_NAME $i" -quiet -force 2>/dev/null || true
done

# 临时目录 — DMG 的内容
DMG_SRC="$BUILD_DIR/dmg_src"
rm -rf "$DMG_SRC"
mkdir -p "$DMG_SRC"
cp -R "$APP_BUNDLE" "$DMG_SRC/"
ln -s /Applications "$DMG_SRC/Applications"

# 创建临时可读写 DMG
TMP_DMG="$BUILD_DIR/tmp.dmg"
rm -f "$TMP_DMG"

# 计算所需大小（app 大小 + 余量）
APP_SIZE_KB=$(du -sk "$APP_BUNDLE" | cut -f1)
DMG_SIZE_KB=$((APP_SIZE_KB + 20480))  # +20MB headroom

hdiutil create -volname "$APP_NAME" \
    -srcfolder "$DMG_SRC" \
    -size "${DMG_SIZE_KB}k" \
    -fs HFS+ \
    -format UDRW \
    -ov \
    "$TMP_DMG"

# ──────────────────────────────────
# Step 5: 挂载 → 调布局 → 卸载
# ──────────────────────────────────
echo ""
echo "🎨 [5/5] 调整 DMG 窗口布局..."

DEVICE=$(hdiutil attach -readwrite -noverify -noautoopen "$TMP_DMG" | awk '/Apple_HFS/ {print $1; exit}')
sleep 1

if [ -z "$DEVICE" ]; then
    echo "  ⚠️ 无法挂载 DMG，跳过布局调整"
else
    # 确保脚本退出或出错时一定会卸载
    trap "hdiutil detach '$DEVICE' -quiet -force 2>/dev/null || true" EXIT

    osascript << APPLESCRIPT
tell application "Finder"
    tell disk "$APP_NAME"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set bounds of container window to {100, 100, 560, 420}
        set theViewOptions to the icon view options of container window
        set arrangement of theViewOptions to not arranged
        set icon size of theViewOptions to 96
        set position of item "$APP_NAME.app" to {125, 140}
        set position of item "Applications" to {335, 140}
        update without registering applications
        delay 1
        close
    end tell
end tell
APPLESCRIPT

    # 等待 Finder 写入完
    sleep 2
    hdiutil detach "$DEVICE" -quiet -force
    trap - EXIT
fi

# ──────────────────────────────────
# 转换为压缩只读 DMG
# ──────────────────────────────────
echo "  压缩中..."
hdiutil convert "$TMP_DMG" -format UDZO -imagekey zlib-level=9 -o "$DMG_PATH" -quiet
rm -f "$TMP_DMG"

# 清理
rm -rf "$DMG_SRC"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ DMG 打包完成！"
echo "  📀 $DMG_PATH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  使用方法: 双击打开 DMG，把 MDmaker.app 拖到 Applications 文件夹即可。"
