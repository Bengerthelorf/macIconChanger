//
//  ChangeView.swift
//  IconChanger
//
//  Created by 朱浩宇 on 2022/4/27.
//

import SwiftUI
import UniformTypeIdentifiers
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

    @StateObject private var iconManager = IconManager.shared

    @State var isExpanded: Bool = false

    @State var importedImageURL: URL? = nil

    @State var setAlias: String? = nil

    @State var selectedStyle: IconStyle = .all
    @State private var loadIconsTask: Task<Void, Never>? = nil
    @State private var currentLoadToken = UUID()
    @State private var showRestoreConfirm = false
    @State private var restoreError: String?
    @State private var setIconError: String?
    @State private var isDragOver = false
    @State private var hasDuplicateName = false

    var body: some View {
        GeometryReader { geometry in
            let computedColumns = Int((geometry.size.width - 2 * minGridSpacing) / (imageSize + minGridSpacing))
            let numberOfColumns = max(1, computedColumns)
            let columns = Array(repeating: GridItem(.fixed(imageSize), spacing: minGridSpacing), count: numberOfColumns)

            ScrollView() {
                VStack {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(setPath.name)
                            .font(.title)
                        if hasDuplicateName {
                            Text("(\(setPath.displayPath))")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button {
                            showRestoreConfirm = true
                        } label: {
                            Label("Restore Default", systemImage: "arrow.uturn.backward")
                        }
                        .keyboardShortcut(.delete, modifiers: .command)
                        .help("Restore the original app icon")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    HStack {
                        Text("Local")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        Button("Choose from the Local") {
                            chooseLocalIcon()
                        }
                        .keyboardShortcut("o", modifiers: .command)
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
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.accentColor, lineWidth: 3)
                        .background(Color.accentColor.opacity(0.1).cornerRadius(12))
                        .opacity(isDragOver ? 1 : 0)
                        .animation(.easeInOut(duration: 0.15), value: isDragOver)
                )
                .onDrop(of: [.image, .fileURL], isTargeted: $isDragOver) { providers in
                    handleDrop(providers: providers)
                }
                .onChange(of: importedImageURL) { url in
                    guard let url = url else { return }
                    defer { importedImageURL = nil }
                    if let nsimage = NSImage(contentsOf: url) {
                        do {
                            try IconManager.shared.setImage(nsimage, app: setPath)
                        } catch {
                            setIconError = error.localizedDescription
                        }
                    }
                }
                .padding(10)
                .onAppear {
                    inIcons = iconManager.getIconInPath(setPath.url)
                    hasDuplicateName = iconManager.apps.contains { $0.name == setPath.name && $0.id != setPath.id }
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
                    inIcons = iconManager.getIconInPath(setPath.url)
                }
                .confirmationDialog("Restore Default Icon", isPresented: $showRestoreConfirm) {
                    Button("Restore", role: .destructive) {
                        do {
                            try iconManager.removeIcon(from: setPath)
                        } catch {
                            restoreError = error.localizedDescription
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("This will remove the custom icon and restore the original icon for \(setPath.name).")
                }
                .alert("Restore Failed", isPresented: Binding(
                    get: { restoreError != nil },
                    set: { if !$0 { restoreError = nil } }
                )) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(Self.friendlyErrorMessage(restoreError ?? ""))
                }
                .alert("Failed to Set Icon", isPresented: Binding(
                    get: { setIconError != nil },
                    set: { if !$0 { setIconError = nil } }
                )) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(Self.friendlyErrorMessage(setIconError ?? ""))
                }
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }

        // Try file URL first (covers dragged files from Finder)
        if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                guard let data = item as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
                let imageTypes: Set<String> = ["png", "jpg", "jpeg", "tiff", "tif", "icns", "heic", "webp", "bmp", "gif", "svg"]
                guard imageTypes.contains(url.pathExtension.lowercased()) else { return }
                DispatchQueue.main.async {
                    importedImageURL = url
                }
            }
            return true
        }

        // Try image data directly (covers dragged images from other apps)
        if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { item, _ in
                if let url = item as? URL {
                    DispatchQueue.main.async {
                        importedImageURL = url
                    }
                } else if let data = item as? Data, let image = NSImage(data: data) {
                    // Save to temp file and set URL
                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("dropped_icon_\(UUID().uuidString).png")
                    if let tiffData = image.tiffRepresentation,
                       let bitmapRep = NSBitmapImageRep(data: tiffData),
                       let pngData = bitmapRep.representation(using: .png, properties: [:]) {
                        try? pngData.write(to: tempURL)
                        DispatchQueue.main.async {
                            importedImageURL = tempURL
                        }
                    }
                }
            }
            return true
        }

        return false
    }

    private func chooseLocalIcon() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image, .icns]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.begin { response in
            if response == .OK, let url = panel.url {
                importedImageURL = url
            }
        }
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
                    isLoadingIcons = false
                }
            }
        }
    }
    
    private static func friendlyErrorMessage(_ raw: String) -> String {
        if raw.contains("permission") || raw.contains("权限") {
            return NSLocalizedString("This app may be protected by macOS. Try closing the app first, or the app may not support icon changes.", comment: "Permission error explanation")
        }
        return raw
    }

    private func updateIconStatus(icon: IconRes, isValid: Bool) {
        if !isValid && icon.isValidIcon {
            icon.isValidIcon = false
            if successIconsCount > 0 {
                successIconsCount -= 1
            }
            validIcons.removeAll { $0.id == icon.id }
        } else if isValid && !icon.isValidIcon {
            icon.isValidIcon = true
            successIconsCount += 1
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
