//
//  LocalImageView.swift
//  IconChanger
//

import SwiftUI
import LaunchPadManagerDBHelper

struct LocalImageView: View {
    let url: URL
    let setPath: AppItem
    
    @State var nsimage: NSImage?
    @State var isLoading: Bool = true

    var onFavorite: ((NSImage) -> Void)? = nil

    var body: some View {
        ImageViewCore(nsimage: $nsimage, setPath: setPath, isLoading: $isLoading)
            .contextMenu {
                Button {
                    if let image = nsimage {
                        onFavorite?(image)
                    }
                } label: {
                    Label("Add to Favorites", systemImage: "star")
                }
                .disabled(nsimage == nil)
            }
            .task(id: url) {
                do {
                    isLoading = true
                    let localUrl = url

                    let image = try await IconImageLoader.shared.image(for: localUrl)

                    await MainActor.run {
                        nsimage = image
                        isLoading = false
                    }
                } catch {
                    await MainActor.run {
                        isLoading = false
                    }
                }
            }
    }
}
