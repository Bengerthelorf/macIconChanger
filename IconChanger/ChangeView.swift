//
//  ChangeView.swift
//  IconChanger
//
//  Created by 朱浩宇 on 2022/4/27.
//  Modified by seril on 2023/7/25.
//  Modified by Bengerthelorf on 2025/3/21.
//

import SwiftUI
import LaunchPadManagerDBHelper

struct ChangeView: View {
    let imageSize: CGFloat = 96
    let minGridSpacing: CGFloat = 8

    @State var icons: [IconRes] = []
    @State var inIcons: [URL] = []
    @State var showProgress = false
    @State var isLoadingIcons = true
    @State var totalIconsCount: Int = 0
    @State var successIconsCount: Int = 0
    @State var validIcons: [IconRes] = []  // 新增：保存成功加载的图标
    let setPath: LaunchPadManagerDBHelper.AppInfo

    @Environment(\.presentationMode) var presentationMode

    @StateObject var iconManager = IconManager.shared

    @State var isExpanded: Bool = false

    @State var importImage = false

    @State var setAlias: String? = nil

    var body: some View {
        GeometryReader { geometry in
            let numberOfColumns = Int((geometry.size.width - 2 * minGridSpacing) / (imageSize + minGridSpacing))
            let columns = Array(repeating: GridItem(.fixed(imageSize), spacing: minGridSpacing), count: numberOfColumns)

            ScrollView() {
                VStack {
                    Text(setPath.name).font(.title).frame(maxWidth: .infinity, alignment: .leading)
                    HStack {
                        Text("Local")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        Button("Choose from the Local") {
                            importImage.toggle()
                        }
                    }

                    if inIcons.isEmpty {
                        ProgressView()
                                .progressViewStyle(AppStoreProgressViewStyle())
                    } else {
                        LazyVGrid(columns: columns, alignment: .leading) {
                            ForEach(inIcons.prefix(isExpanded ? inIcons.count : numberOfColumns), id: \.self) { icon in
                                LocalImageView(url: icon, setPath: setPath)
                                        .frame(width: imageSize, height: imageSize)
                            }
                        }
                        if !isExpanded && inIcons.count > numberOfColumns {
                            Button(action: {
                                isExpanded = true
                            }) {
                                Text("Show More")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                            }
                        }
                    }

                    Divider().padding(.top, 10)
                            .padding(.bottom, 10)

                    HStack {
                        Text("macOSicons.com")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if !isLoadingIcons && successIconsCount > 0 {
                            HStack(spacing: 4) {
                                Text("\(successIconsCount)/\(totalIconsCount)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    if isLoadingIcons {
                        VStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(AppStoreProgressViewStyle())
                            Spacer()
                        }
                    } else if validIcons.isEmpty {
                        VStack {
                            Spacer()
                            Text("No Icons Found")
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .padding()
                            Text("You can modify the alias name for better results")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Button("Set Alias Name") {
                                setAlias = setPath.url.deletingPathExtension().lastPathComponent
                            }
                            .padding(.top, 8)
                            Spacer()
                        }
                    } else {
                        ZStack {
                            LazyVGrid(columns: columns, alignment: .leading) {
                                ForEach(validIcons) { icon in
                                    ImageView(icon: icon, setPath: setPath, onStatusUpdate: { isValid in
                                        updateIconStatus(icon: icon, isValid: isValid)
                                    })
                                    .frame(width: imageSize, height: imageSize)
                                }
                            }
                        }
                    }
                }
                        .padding()
            }
        }
                .fileImporter(isPresented: $importImage, allowedContentTypes: [.image, .icns]) { result in
                    switch result {
                    case .success(let url):
                        if url.startAccessingSecurityScopedResource() {
                            if let nsimage = NSImage(contentsOf: url) {
                                do {
                                    try IconManager.shared.setImage(nsimage, app: setPath)
                                } catch {
                                    fatalError(error.localizedDescription)
                                }
                            }
                            url.stopAccessingSecurityScopedResource()
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
                .padding(10)
                .onAppear {
                    inIcons = iconManager.getIconInPath(setPath.url)
                }
                .task {
                    do {
                        isLoadingIcons = true
                        icons = try await iconManager.getIcons(setPath)
                        totalIconsCount = icons.count
                        successIconsCount = icons.count  // 初始时假设所有图标都可加载
                        validIcons = icons  // 初始时将所有图标视为有效
                        isLoadingIcons = false
                    } catch {
                        print(error)
                        isLoadingIcons = false
                    }
                }
                .sheet(item: $setAlias) {
                    SetAliasNameView(raw: $0, lastText: AliasName.getName(for: $0) ?? "")
                }
//                .navigationTitle(setPath.name)
    }
    
    // 更新图标状态和计数的函数
    private func updateIconStatus(icon: IconRes, isValid: Bool) {
        // 如果状态变为无效，且之前是有效的
        if !isValid && icon.isValidIcon {
            icon.isValidIcon = false
            if successIconsCount > 0 {
                successIconsCount -= 1
            }
            
            // 从validIcons数组中移除无效图标
            validIcons.removeAll { $0.id == icon.id }
        }
        // 如果状态变为有效，且之前是无效的 (理论上不会发生，但保留以防万一)
        else if isValid && !icon.isValidIcon {
            icon.isValidIcon = true
            successIconsCount += 1
            
            // 确保图标在validIcons数组中
            if !validIcons.contains(where: { $0.id == icon.id }) {
                validIcons.append(icon)
            }
        }
    }
}

struct AppStoreProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            ProgressView(configuration)
                    .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                    .scaleEffect(0.5, anchor: .center)
            Text("Loading")
                    .font(.footnote)
                    .foregroundColor(.primary)
        }
    }
}
