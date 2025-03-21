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
    @State var isLoading: Bool = true  // 添加加载状态标志
    
    // 添加一个回调，通知父视图图标加载状态变化
    var onStatusUpdate: ((Bool) -> Void)? = nil

    var body: some View {
        ImageViewCore(nsimage: $preview, setPath: setPath, isLoading: $isLoading)
                .task {
                    do {
                        isLoading = true  // 开始加载
                        preview = try await MyRequestController().sendRequest(icon.lowResPngUrl)
                        if preview == nil {
                            // 图标加载失败
                            isLoading = false
                            // 通知父视图更新状态
                            onStatusUpdate?(false)
                        } else {
                            // 图标加载成功
                            onStatusUpdate?(true)
                        }
                    } catch {
                        print(error)
                        isLoading = false  // 加载失败
                        // 通知父视图更新状态
                        onStatusUpdate?(false)
                    }
                }
    }
}

