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
    @StateObject var iconManager = IconManager.shared

    let rules = [GridItem(.adaptive(minimum: 100), alignment: .top)]

    @State var setPath: LaunchPadManagerDBHelper.AppInfo? = nil
    @State var selectedApp: LaunchPadManagerDBHelper.AppInfo? = nil

    @State var searchText: String = ""
    @State var setAlias: String?

    var body: some View {
        NavigationView {
            List(selection: $selectedApp) {
                ForEach(iconManager.apps.filter { app in
                    searchText.isEmpty || app.name.localizedStandardContains(searchText)
                }, id: \.url) { app in
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

                                Button("Remove the Icon from the Launchpad") {
                                    do {
                                        try LaunchPadManagerDBHelper().removeApp(app)
                                    } catch {
                                        print(error)
                                    }
                                }
                            }
                }
            }
                    .listStyle(SidebarListStyle())  // Use SidebarListStyle to create a sidebar look
                    .frame(minWidth: 200, idealWidth: 300) // Adjust the width to your liking

            // Display detail view when an app is selected, otherwise display placeholder
            if let app = selectedApp {
                ChangeView(setPath: app)
            } else {
                Text("Select an app to see its details")
                        .foregroundColor(.secondary)
            }
        }

                .sheet(item: $setAlias) {
                    SetAliasNameView(raw: $0, lastText: AliasName.getName(for: $0) ?? "")
                }
                .searchable(text: $searchText)
                .toolbar {
                    ToolbarItem {
                        Menu {
                            Button("Check Setup Status") {
                                print("Manual setup check requested.")
                                iconManager.needsSetupCheck = true
                            }
                            
                            Divider()
                            
                            // Add new option to restore cached icons
                            Button {
                                Task {
                                    do {
                                        try await iconManager.restoreAllCachedIcons()
                                        // Show success notification using a simple alert
                                        let alert = NSAlert()
                                        alert.messageText = "Icons Restored"
                                        alert.informativeText = "All cached custom icons have been successfully restored."
                                        alert.alertStyle = .informational
                                        alert.addButton(withTitle: "OK")
                                        alert.runModal()
                                    } catch let error as RestoreError {
                                        // Show error notification
                                        let alert = NSAlert()
                                        alert.messageText = "Error Restoring Icons"
                                        alert.informativeText = error.localizedDescription
                                        alert.alertStyle = .critical
                                        alert.addButton(withTitle: "OK")
                                        alert.runModal()
                                    } catch {
                                        // Generic error
                                        let alert = NSAlert()
                                        alert.messageText = "Error Restoring Icons"
                                        alert.informativeText = error.localizedDescription
                                        alert.alertStyle = .critical
                                        alert.addButton(withTitle: "OK")
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

                    ToolbarItem(placement: .automatic) {
                        Button {
                            iconManager.refresh()
                        } label: {
                            Image(systemName: "goforward")
                        }
                    }
//                     Add a new toolbar item to show cache count (optional)
                    ToolbarItem(placement: .automatic) {
                        HStack(spacing: 4) {
                            Image(systemName: "archivebox")
                                .font(.system(size: 12))
                            Text("\(IconCacheManager.shared.getCachedIconsCount())")
                                .font(.caption)
                        }
                        .padding(5)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(5)
                    }
                }
    }

}

struct IconView: View {
    let app: LaunchPadManagerDBHelper.AppInfo

    var body: some View {
        HStack {
            Image(nsImage: NSWorkspace.shared.icon(forFile: app.url.universalPath()))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
            Text(app.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}


extension String: @retroactive Identifiable {
    public var id: String {
        self
    }
}

struct MyDropDelegate: DropDelegate {
    let app: LaunchPadManagerDBHelper.AppInfo

    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: ["public.file-url"])
    }

    func performDrop(info: DropInfo) -> Bool {
        if let item = info.itemProviders(for: ["public.file-url"]).first {
            item.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (urlData, error) in
                Task {
                    if let urlData = urlData as? Data {
                        let url = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL

                        if let nsimage = NSImage(contentsOf: url) {
                            do {
                                try await IconManager.shared.setImage(nsimage, app: app)
                            } catch {
                                fatalError(error.localizedDescription)
                            }
                        }
                    }
                }
            }

            return true

        } else {
            return false
        }
    }
}
