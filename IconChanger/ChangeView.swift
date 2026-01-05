//
//  ChangeView.swift
//  IconChanger
//
//  Created by 朱浩宇 on 2022/4/27.
//  Modified by seril on 2023/7/25.
//  Modified by Bengerthelorf on 2025/3/21.
//  Modified by CantonMonkey on 2025/10/10.
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
    @State var validIcons: [IconRes] = []
    let setPath: AppItem

    @Environment(\.presentationMode) var presentationMode

    @StateObject var iconManager = IconManager.shared

    @State var isExpanded: Bool = false

    @State var importImage = false

    @State var setAlias: String? = nil

    // icon style selector
    @State var selectedStyle: IconStyle = .all
    @State private var loadIconsTask: Task<Void, Never>? = nil
    @State private var currentLoadToken = UUID()

    var body: some View {
        GeometryReader { geometry in
            let computedColumns = Int((geometry.size.width - 2 * minGridSpacing) / (imageSize + minGridSpacing))
            let numberOfColumns = max(1, computedColumns)
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
                        
                        // Style selector
                        Picker("Style", selection: $selectedStyle) {
                            ForEach(IconStyle.allCases) { style in
                                Text(style.displayName).tag(style)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: selectedStyle) { _ in
                            triggerIconFetch()
                        }
                        
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
                    triggerIconFetch()
                }
                .sheet(item: $setAlias) {
                    SetAliasNameView(raw: $0, lastText: AliasName.getName(for: $0) ?? "")
                }
                .onDisappear {
                    loadIconsTask?.cancel()
                }
                .onChange(of: iconManager.iconRefreshTrigger) { _ in
                    triggerIconFetch()
                }
//                .navigationTitle(setPath.name)
    }
    
    private func triggerIconFetch() {
        loadIconsTask?.cancel()
        let token = UUID()
        currentLoadToken = token
        let style = selectedStyle
        let appInfo = setPath

        loadIconsTask = Task {
            await fetchIcons(for: appInfo, style: style, token: token)
        }
    }

    private func fetchIcons(for appInfo: AppItem,
                            style: IconStyle,
                            token: UUID) async {
        await MainActor.run {
            if currentLoadToken == token {
                isLoadingIcons = true
            }
        }

        do {
            let fetchedIcons = try await iconManager.getIcons(appInfo, style: style)

            if Task.isCancelled {
                await MainActor.run {
                    if currentLoadToken == token {
                        isLoadingIcons = false
                    }
                }
                return
            }

            await MainActor.run {
                guard currentLoadToken == token else { return }
                icons = fetchedIcons
                totalIconsCount = fetchedIcons.count
                successIconsCount = fetchedIcons.count
                validIcons = fetchedIcons
                isLoadingIcons = false
            }
        } catch is CancellationError {
            await MainActor.run {
                if currentLoadToken == token {
                    isLoadingIcons = false
                }
            }
        } catch {
            await MainActor.run {
                if currentLoadToken == token {
                    print(error)
                    isLoadingIcons = false
                }
            }
        }
    }
    
    // Function to update the icon status and count
    private func updateIconStatus(icon: IconRes, isValid: Bool) {
        // If the status becomes invalid and was previously valid
        if !isValid && icon.isValidIcon {
            icon.isValidIcon = false
            if successIconsCount > 0 {
                successIconsCount -= 1
            }
            
            // Remove invalid icons from the validIcons array
            validIcons.removeAll { $0.id == icon.id }
        }
        // If the status becomes valid and was previously invalid (theoretically won't happen, but kept just in case)
        else if isValid && !icon.isValidIcon {
            icon.isValidIcon = true
            successIconsCount += 1
            
            // Ensure the icon is in the validIcons array
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
