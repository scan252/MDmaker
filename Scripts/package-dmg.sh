#!/bin/bash
set -e
cd "$(dirname "$0")/.."
PROJECT_DIR="$(pwd)"
APP_NAME="MDmaker"
VERSION=$(grep -A1 'CFBundleShortVersionString' Info.plist | tail -1 | sed 's/.*<string>\(.*\)<\/string>.*/\1/')
BUILD_DIR="$PROJECT_DIR/.build/dmg"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
DMG_NAME="$APP_NAME-$VERSION.dmg"
DMG_PATH="$PROJECT_DIR/$DMG_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📦 打包 $APP_NAME v$VERSION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔨 [1/5] 编译 release 版本..."
swift build -c release
echo ""
echo "📁 [2/5] 构建 .app bundle..."
rm -rf "$BUILD_DIR"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"
cp "$PROJECT_DIR/.build/release/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
cp "$PROJECT_DIR/Info.plist" "$APP_BUNDLE/Contents/Info.plist"
swift "$PROJECT_DIR/Scripts/generate-icon.swift" "$APP_BUNDLE/Contents/Resources/AppIcon.iconset" 2>/dev/null
iconutil -c icns "$APP_BUNDLE/Contents/Resources/AppIcon.iconset" -o "$APP_BUNDLE/Contents/Resources/AppIcon.icns" 2>/dev/null
rm -rf "$APP_BUNDLE/Contents/Resources/AppIcon.iconset"
echo "  ✓ $APP_BUNDLE"
echo ""
echo "🔐 [3/5] 临时签名..."
codesign --force --deep --sign - "$APP_BUNDLE" 2>/dev/null && echo "  ✓ 已 ad-hoc 签名" || echo "  ⚠️ 签名跳过（不影响本地使用）"
echo ""
echo "💿 [4/5] 创建 DMG..."
rm -f "$DMG_PATH"
hdiutil detach "/Volumes/$APP_NAME" -quiet -force 2>/dev/null || true
for i in 1 2 3 4 5; do hdiutil detach "/Volumes/$APP_NAME $i" -quiet -force 2>/dev/null || true; done
DMG_SRC="$BUILD_DIR/dmg_src"
rm -rf "$DMG_SRC"
mkdir -p "$DMG_SRC"
cp -R "$APP_BUNDLE" "$DMG_SRC/"
ln -s /Applications "$DMG_SRC/Applications"
TMP_DMG="$BUILD_DIR/tmp.dmg"
rm -f "$TMP_DMG"
APP_SIZE_KB=$(du -sk "$APP_BUNDLE" | cut -f1)
DMG_SIZE_KB=$((APP_SIZE_KB + 20480))
hdiutil create -volname "$APP_NAME" -srcfolder "$DMG_SRC" -size "${DMG_SIZE_KB}k" -fs HFS+ -format UDRW -ov "$TMP_DMG"
echo ""
echo "🎨 [5/5] 调整 DMG 窗口布局..."
DEVICE=$(hdiutil attach -readwrite -noverify -noautoopen "$TMP_DMG" | awk '/Apple_HFS/ {print $1; exit}')
sleep 1
if [ -z "$DEVICE" ]; then
    echo "  ⚠️ 无法挂载 DMG，跳过布局调整"
else
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
    sleep 2
    hdiutil detach "$DEVICE" -quiet -force
    trap - EXIT
fi
echo "  压缩中..."
hdiutil convert "$TMP_DMG" -format UDZO -imagekey zlib-level=9 -o "$DMG_PATH" -quiet
rm -f "$TMP_DMG"
rm -rf "$DMG_SRC"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ DMG 打包完成！"
echo "  📀 $DMG_PATH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
