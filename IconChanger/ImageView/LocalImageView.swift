//
//  LocalImageView.swift
//  IconChanger
//
//  Created by 朱浩宇 on 2022/12/18.
//  Modified by seril on 2023/7/25.
//  Modified by Bengerthelorf on 2025/3/21.
//

import SwiftUI
import LaunchPadManagerDBHelper

struct LocalImageView: View {
    let url: URL
    let setPath: LaunchPadManagerDBHelper.AppInfo

    @State var nsimage: NSImage?
    @State var isLoading: Bool = true

    var body: some View {
        ImageViewCore(nsimage: $nsimage, setPath: setPath, isLoading: $isLoading)
                .task {
                    do {
                        isLoading = true
                        let image = try await MyRequestController().sendRequest(url)
                        await MainActor.run {
                            nsimage = image
                            if nsimage == nil {
                                isLoading = false
                            }
                        }
                    } catch {
                        await MainActor.run {
                            print(error)
                            isLoading = false
                        }
                    }
                }
    }
}