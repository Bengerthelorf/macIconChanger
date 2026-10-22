#!/usr/bin/env python3
"""Run the production folder routing/API against disposable folders, never apps."""
from pathlib import Path
import subprocess
import tempfile

source = Path("IconChanger/Services/IconManager.swift").read_text()
start = source.index("    func runHelperTool(")
end = source.index("    private func runHelper(\n", start)
routes = source[start:end]
start = source.index("    func hasCustomIcon(")
end = source.index("    /// Escapes", start)
probe = source[start:end]
fixture = r'''import AppKit
enum UIReviewMode { static func requireLiveApplication() throws {} }
enum ImageSaveError: Error { case cgImageConversionFailed }
enum Operation { case replace }
struct DiagnosticsContext {
    init(operation: Operation, appPath: String, iconKind: String, iconPath: String) {}
    init() {}
}
struct AppItem { let name: String; let url: URL; let originalAppInfo: String? }
extension URL { func universalPath() -> String { path } }
enum Unexpected: Error { case privilegedHelper }
class Fixture {
    let fileiconURL = URL(fileURLWithPath: "/not-executed/fileicon")
    func runHelper(arguments: [String], operation: String, appPath: String, diagnosticsContext: DiagnosticsContext) throws {
        throw Unexpected.privilegedHelper
    }
    func removeFolder(at path: String) throws { try runHelperRemove(appPath: path, diagnosticsContext: DiagnosticsContext()) }
''' + routes + probe + r'''}
let fm = FileManager.default
let root = fm.temporaryDirectory.appendingPathComponent("iconchanger-folder-test-" + UUID().uuidString)
try fm.createDirectory(at: root, withIntermediateDirectories: true)
defer { try? fm.removeItem(at: root) }
let folder = root.appendingPathComponent("Test Folder")
try fm.createDirectory(at: folder, withIntermediateDirectories: true)
let image = NSImage(size: NSSize(width: 64, height: 64), flipped: false) { rect in
    NSColor.red.setFill(); rect.fill(); return true
}
let cg = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
let png = NSBitmapImageRep(cgImage: cg).representation(using: .png, properties: [:])!
let imageURL = root.appendingPathComponent("icon.png")
try png.write(to: imageURL)
let manager = Fixture()
let item = AppItem(name: "Folder", url: folder, originalAppInfo: nil)
for _ in 0..<2 {
    try manager.runHelperTool(appPath: folder.path, imagePath: imageURL.path)
    precondition(manager.hasCustomIcon(app: item), "folder apply/restore must retain a custom icon")
    try manager.removeFolder(at: folder.path)
    precondition(!manager.hasCustomIcon(app: item), "folder remove/undo-to-default must clear custom icon")
}
let link = root.appendingPathComponent("Link")
try fm.createSymbolicLink(at: link, withDestinationURL: folder)
do {
    try manager.runHelperTool(appPath: link.path, imagePath: imageURL.path)
    preconditionFailure("symlinks must not become writable folder targets")
} catch { }
print("PASS: real folder set/remove/restore use public API without the administrator helper")
'''
with tempfile.TemporaryDirectory(prefix="iconchanger-folder-fixture-") as tmp:
    swift = Path(tmp) / "main.swift"
    binary = Path(tmp) / "test"
    swift.write_text(fixture)
    subprocess.run(["swiftc", "IconChanger/Services/IconInteractionPolicy.swift", str(swift), "-o", str(binary)], check=True)
    subprocess.run([str(binary)], check=True)
