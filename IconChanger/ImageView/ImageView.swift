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
    let setPath: LaunchPadManagerDBHelper.AppInfo
    @State var preview: NSImage?
    @State var isLoading: Bool = true
    
    var onStatusUpdate: ((Bool) -> Void)? = nil

    var body: some View {
        ImageViewCore(nsimage: $preview, setPath: setPath, isLoading: $isLoading)
            .task {
                do {
                    isLoading = true
                    // Create strong local references
                    let iconUrl = icon.lowResPngUrl
                    
                    // Load the image
                    let image = try await MyRequestController().sendRequest(iconUrl)
                    
                    // Update UI on the main thread
                    await MainActor.run {
                        preview = image
                        isLoading = image == nil
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

