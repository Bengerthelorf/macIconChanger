//
//  ApplicationFolderSettingsView.swift
//  IconChanger
//

import SwiftUI

struct ApplicationFolderSettingsView: View {
    @StateObject private var folderPermission = FolderPermission.shared
    @State private var selectedId: UUID?

    var body: some View {
        VStack {
            HStack {
                Text("Application Folders")
                        .font(.headline)
                Spacer()
                Button(action: {
                    folderPermission.add()
                }) {
                    Image(systemName: "plus")
                }

                Button(action: {
                    if let id = selectedId {
                        folderPermission.removeBookmark(id: id)
                        selectedId = nil
                    }
                }) {
                    Image(systemName: "minus")
                }
                        .disabled(selectedId == nil)
            }
                    .buttonStyle(.borderless)

            Table(folderPermission.permissions, selection: $selectedId) {
                TableColumn("Folder", value: \.path)

            }
                    .onAppear {
                        folderPermission.check()
                    }

        }

    }
}
