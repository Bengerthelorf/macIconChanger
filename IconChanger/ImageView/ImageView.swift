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
    @State var isLoading: Bool = true  // Add loading state flag
    
    // Add a callback to notify the parent view of icon loading status changes
    var onStatusUpdate: ((Bool) -> Void)? = nil

    var body: some View {
        ImageViewCore(nsimage: $preview, setPath: setPath, isLoading: $isLoading)
                .task {
                    do {
                        isLoading = true  // Start loading
                        preview = try await MyRequestController().sendRequest(icon.lowResPngUrl)
                        if preview == nil {
                            // Icon loading failed
                            isLoading = false
                            // Notify the parent view to update the status
                            onStatusUpdate?(false)
                        } else {
                            // Icon loading succeeded
                            onStatusUpdate?(true)
                        }
                    } catch {
                        print(error)
                        isLoading = false  // Loading failed
                        // Notify the parent view to update the status
                        onStatusUpdate?(false)
                    }
                }
    }
}

