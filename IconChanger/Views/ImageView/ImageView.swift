//
//  ImageView.swift
//  IconChanger
//

import SwiftUI
import LaunchPadManagerDBHelper

struct ImageView: View {
    let icon: IconRes
    let setPath: AppItem
    @State var preview: NSImage?
    @State var isLoading: Bool = true
    
    var onStatusUpdate: ((Bool) -> Void)? = nil

    var onFavorite: ((NSImage) -> Void)? = nil

    var body: some View {
        ImageViewCore(nsimage: $preview, setPath: setPath, isLoading: $isLoading)
            .contextMenu {
                Button {
                    if let image = preview {
                        onFavorite?(image)
                    }
                } label: {
                    Label("Add to Favorites", systemImage: "star")
                }
                .disabled(preview == nil)
            }
            .task(id: icon.id) {
                do {
                    isLoading = true
                    let iconUrl = icon.lowResPngUrl

                    let image = try await IconImageLoader.shared.image(for: iconUrl)

                    await MainActor.run {
                        preview = image
                        isLoading = false
                        onStatusUpdate?(image != nil)
                    }
                } catch {
                    await MainActor.run {
                        isLoading = false
                        onStatusUpdate?(false)
                    }
                }
            }
    }
}
