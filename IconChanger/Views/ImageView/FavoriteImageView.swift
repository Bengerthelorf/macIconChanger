//
//  FavoriteImageView.swift
//  IconChanger
//

import SwiftUI

struct FavoriteImageView: View {
    let favorite: FavoriteIcon
    let setPath: AppItem
    let onRemove: () -> Void

    @State private var nsimage: NSImage?
    @State private var isLoading = true

    var body: some View {
        ImageViewCore(nsimage: $nsimage, setPath: setPath, isLoading: $isLoading)
            .contextMenu {
                Button(role: .destructive) {
                    onRemove()
                } label: {
                    Label("Remove from Favorites", systemImage: "star.slash")
                }
            }
            .task(id: favorite.id) {
                let url = IconFavoriteManager.shared.getIconURL(for: favorite)
                if let image = NSImage(contentsOf: url) {
                    nsimage = image
                }
                isLoading = false
            }
    }
}
