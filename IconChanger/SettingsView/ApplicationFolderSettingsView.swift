//
//  ApplicationFolderSettingsView.swift
//  IconChanger
//
//  Created by seril on 7/25/23.
//

import SwiftUI

struct ApplicationFolderSettingsView: View {
    @ObservedObject var folderPermission = FolderPermission.shared
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
                    .onChange(of: selectedId) { newValue in
                        // Handle selection change if needed
                    }
                    .onAppear {
                        folderPermission.check()
                    }

        }

    }
}
