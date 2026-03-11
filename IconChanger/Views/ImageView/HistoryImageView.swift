//
//  HistoryImageView.swift
//  IconChanger
//

import SwiftUI

struct HistoryImageView: View {
    let entry: IconHistoryEntry
    let setPath: AppItem
    let onFavorite: (NSImage) -> Void
    let onRemove: () -> Void

    @State private var nsimage: NSImage?
    @State private var isLoading = true

    var body: some View {
        ImageViewCore(nsimage: $nsimage, setPath: setPath, isLoading: $isLoading)
            .contextMenu {
                Button {
                    if let image = nsimage {
                        onFavorite(image)
                    }
                } label: {
                    Label("Add to Favorites", systemImage: "star")
                }
                .disabled(nsimage == nil)

                Divider()

                Button(role: .destructive) {
                    onRemove()
                } label: {
                    Label("Remove from History", systemImage: "trash")
                }
            }
            .overlay(alignment: .bottom) {
                Text(entry.timestamp, style: .date)
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .padding(.bottom, 2)
            }
            .task(id: entry.id) {
                let url = IconHistoryManager.shared.getIconURL(for: entry)
                if let image = NSImage(contentsOf: url) {
                    nsimage = image
                }
                isLoading = false
            }
    }
}
