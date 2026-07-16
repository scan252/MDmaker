#!/usr/bin/env swift
import AppKit
import Foundation
let bgColor = NSColor(calibratedRed: 0.15, green: 0.16, blue: 0.18, alpha: 1.0)
let accentColor = NSColor(calibratedRed: 0.35, green: 0.65, blue: 0.95, alpha: 1.0)
let sizes: [(name: String, px: Int)] = [
    ("icon_16x16", 16), ("icon_16x16@2x", 32),
    ("icon_32x32", 32), ("icon_32x32@2x", 64),
    ("icon_128x128", 128), ("icon_128x128@2x", 256),
    ("icon_256x256", 256), ("icon_256x256@2x", 512),
    ("icon_512x512", 512), ("icon_512x512@2x", 1024),
]
let outputDir: String
if CommandLine.arguments.count > 1 { outputDir = CommandLine.arguments[1] }
else {
    let scriptDir = URL(fileURLWithPath: #file).deletingLastPathComponent().path
    outputDir = "\(scriptDir)/../MDmaker.app/Contents/Resources/AppIcon.iconset"
}
let fm = FileManager.default
try? fm.removeItem(atPath: outputDir)
try fm.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
func drawIcon(size: CGFloat, scale: CGFloat) -> NSImage {
    let canvasSize = size * scale
    let image = NSImage(size: NSSize(width: canvasSize, height: canvasSize))
    image.lockFocus()
    let cornerRadius = canvasSize * 0.225
    let bgPath = NSBezierPath(roundedRect: NSRect(x: 0, y: 0, width: canvasSize, height: canvasSize), xRadius: cornerRadius, yRadius: cornerRadius)
    bgColor.setFill(); bgPath.fill()
    let barWidth = canvasSize * 0.18
    let barRect = NSRect(x: canvasSize * 0.15, y: canvasSize * 0.22, width: barWidth, height: canvasSize * 0.56)
    let barPath = NSBezierPath(roundedRect: barRect, xRadius: barWidth / 3, yRadius: barWidth / 3)
    accentColor.setFill(); barPath.fill()
    let fontSize = canvasSize * 0.48
    let attr: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: fontSize, weight: .bold), .foregroundColor: NSColor.white]
    let text = "MD"
    let textSize = text.size(withAttributes: attr)
    let textX = canvasSize * 0.18 + barWidth + (canvasSize * 0.82 - barWidth - textSize.width) / 2
    let textY = (canvasSize - textSize.height) / 2
    text.draw(at: NSPoint(x: textX, y: textY), withAttributes: attr)
    image.unlockFocus()
    return image
}
for (name, px) in sizes {
    let scale: CGFloat = name.contains("@2x") ? 2.0 : 1.0
    let baseSize = CGFloat(px) / scale
    let img = drawIcon(size: baseSize, scale: scale)
    guard let cgImage = img.cgImage(forProposedRect: nil, context: nil, hints: nil) else { continue }
    let rep = NSBitmapImageRep(cgImage: cgImage)
    rep.size = NSSize(width: CGFloat(px), height: CGFloat(px))
    guard let pngData = rep.representation(using: .png, properties: [:]) else { continue }
    try pngData.write(to: URL(fileURLWithPath: "\(outputDir)/\(name).png"))
}
print("✅ iconset 生成完成: \(outputDir)")
