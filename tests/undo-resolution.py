#!/usr/bin/env python3
"""Compile the real snapshot method and check its encoded bitmap resolution."""
from pathlib import Path
import subprocess
import tempfile

source = Path("IconChanger/Services/IconManager.swift").read_text()
start = source.index("    func captureUndoSnapshot(")
end = source.index("    func restoreUndoSnapshot(", start)
method = source[start:end]
fixture = '''import AppKit
struct AppItem { let url: URL; var id: String { url.path } }
struct IconUndoSnapshot { let image: NSImage; let hadCustomIcon: Bool; let cache: String? }
struct IconCacheManager {
    static let shared = IconCacheManager()
    func getIconCache(for path: String) -> String? { nil }
}
class FixtureManager {
    func hasCustomIcon(app: AppItem) -> Bool { true }
''' + method + '''}
let app = AppItem(url: URL(fileURLWithPath: "/System/Applications/Notes.app"))
let snapshot = FixtureManager().captureUndoSnapshot(for: app)
let encoded = snapshot.image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
precondition(encoded.width >= 512 && encoded.height >= 512, "Undo must preserve high resolution, got \\(encoded.width)x\\(encoded.height)")
print("PASS: undo snapshot encodes \\(encoded.width)x\\(encoded.height), preserving high-resolution icon data")
'''
with tempfile.TemporaryDirectory(prefix="iconchanger-undo-resolution-") as tmp:
    swift = Path(tmp) / "main.swift"
    binary = Path(tmp) / "test"
    swift.write_text(fixture)
    subprocess.run(["swiftc", str(swift), "-o", str(binary)], check=True)
    subprocess.run([str(binary)], check=True)
