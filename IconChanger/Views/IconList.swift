//
//  IconList.swift
//  IconChanger
//
//  Created by 朱浩宇 on 2022/4/27.
//  Modified by seril on 2023/7/24.
//  Modified by Bengerthelorf on 2025/3/21.
//

import SwiftUI
import LaunchPadManagerDBHelper

struct IconList: View {
    @ObservedObject var iconManager = IconManager.shared

    @State var selectedApp: AppItem? = nil

    @State var searchText: String = ""
    @State var setAlias: String?

    var body: some View {
        NavigationView {
            List(selection: $selectedApp) {
                ForEach(iconManager.apps.filter { app in
                    searchText.isEmpty || app.name.localizedStandardContains(searchText)
                }, id: \.id) { app in
                    NavigationLink(destination: ChangeView(setPath: app),
                            tag: app,
                            selection: $selectedApp) {
                        IconView(app: app)
                    }
                            .contextMenu {
                                Button("Copy the Name") {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(app.name, forType: .string)
                                }

                                Menu("Path") {
                                    Button("Copy") {
                                        NSPasteboard.general.clearContents()
                                        NSPasteboard.general.setString(app.url.universalPath(), forType: .string)
                                    }

                                    Button("Copy the Path Name") {
                                        NSPasteboard.general.clearContents()
                                        NSPasteboard.general.setString(app.url.deletingPathExtension().lastPathComponent, forType: .string)
                                    }

                                    Button("Show in the Finder") {
                                        NSWorkspace.shared.activateFileViewerSelecting([app.url])
                                    }
                                }

                                Button("Set the Alias") {
                                    setAlias = app.url.deletingPathExtension().lastPathComponent
                                }

                                if let original = app.originalAppInfo {
                                    Button("Remove the Icon from the Launchpad") {
                                        do {
                                            try LaunchPadManagerDBHelper().removeApp(original)
                                        } catch {
                                            print(error)
                                        }
                                    }
                                }
                    }
                }
            }
                    .listStyle(SidebarListStyle())
                    .frame(minWidth: 200, idealWidth: 300)

            Text("Select an app to see its details")
                    .foregroundColor(.secondary)
        }

                .sheet(item: $setAlias) {
                    SetAliasNameView(raw: $0, lastText: AliasName.getName(for: $0) ?? "")
                }
                .searchable(text: $searchText)
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button {
                            iconManager.iconRefreshTrigger = UUID()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .help("Refresh Icon Display")
                    }

                    ToolbarItem(placement: .automatic) {
                        Menu {
                            Button {
                                iconManager.refresh()
                            } label: {
                                Label("Refresh App List", systemImage: "arrow.triangle.2.circlepath")
                            }

                            Button {
                                iconManager.needsSetupCheck = true
                            } label: {
                                Label("Check Setup Status", systemImage: "stethoscope")
                            }

                            Divider()

                            Button {
                                Task {
                                    do {
                                        try await iconManager.restoreAllCachedIcons()
                                        let alert = NSAlert()
                                        alert.messageText = NSLocalizedString("Icons Restored", comment: "Alert title")
                                        alert.informativeText = NSLocalizedString("All cached custom icons have been successfully restored.", comment: "Alert body")
                                        alert.alertStyle = .informational
                                        alert.addButton(withTitle: NSLocalizedString("OK", comment: "Alert button"))
                                        alert.runModal()
                                    } catch {
                                        let alert = NSAlert()
                                        alert.messageText = NSLocalizedString("Error Restoring Icons", comment: "Alert title")
                                        alert.informativeText = error.localizedDescription
                                        alert.alertStyle = .critical
                                        alert.addButton(withTitle: NSLocalizedString("OK", comment: "Alert button"))
                                        alert.runModal()
                                    }
                                }
                            } label: {
                                Label("Restore Cached Icons", systemImage: "arrow.clockwise")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
                .onAppear {
                    iconManager.refresh()
                }
                .onChange(of: iconManager.iconRefreshTrigger) { _ in
                    AppIconCache.shared.removeAll()
                }
    }

}

struct IconView: View {
    let app: AppItem
    @ObservedObject private var iconManager = IconManager.shared
    @State private var icon: NSImage?

    var body: some View {
        HStack {
            Group {
                if let icon {
                    Image(nsImage: icon)
                        .resizable()
                        .scaledToFit()
                } else {
                    Image(nsImage: NSWorkspace.shared.icon(for: .applicationBundle))
                        .resizable()
                        .scaledToFit()
                        .opacity(0.3)
                }
            }
            .frame(width: 32, height: 32)

            Text(app.name)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .task(id: app.url) {
            await loadIcon()
        }
        .onAppear {
            if icon == nil, let cached = AppIconCache.shared.cachedIcon(for: app.url) {
                icon = cached
            }
        }
        .onChange(of: iconManager.iconRefreshTrigger) { _ in
            icon = nil
            Task { await loadIcon() }
        }
    }

    private func loadIcon() async {
        if let cached = AppIconCache.shared.cachedIcon(for: app.url) {
            icon = cached
            return
        }
        let url = app.url
        let loaded = await Task.detached(priority: .userInitiated) {
            AppIconCache.shared.icon(for: url)
        }.value
        icon = loaded
    }
}



extension String: @retroactive Identifiable {
    public var id: String {
        self
    }
}

