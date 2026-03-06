//
//  ImageView.swift
//  IconChanger
//
//  Created by 朱浩宇 on 2022/4/28.
//  Modified by seril on 2023/6/25.
//  Modified by Bengerthelorf on 2025/3/21.
//

import SwiftUI
import LaunchPadManagerDBHelper

struct ImageView: View {
    let icon: IconRes
    let setPath: AppItem
    @State var preview: NSImage?
    @State var isLoading: Bool = true
    
    var onStatusUpdate: ((Bool) -> Void)? = nil

    var body: some View {
        ImageViewCore(nsimage: $preview, setPath: setPath, isLoading: $isLoading)
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
                        print(error)
                        isLoading = false
                        onStatusUpdate?(false)
                    }
                }
            }
    }
}
