//
//  ApplicationAliasSettingsView.swift
//  IconChanger
//

import SwiftUI

struct ApplicationAliasSettingsView: View {
    @State var aliasNames = AliasNames.getAll()
    @State private var validationMessage: String?
    @State private var selectedAlias = Set<AliasName.ID>()
    @State private var sortOrder = [KeyPathComparator(\AliasName.appName)]


    var body: some View {
        VStack {
            HStack {
                Text("Alias Names")
                        .font(.headline)
                Spacer()
                Button(action: {
                    if let draft = aliasNames.first(where: { $0.appName.trimmingCharacters(in: .whitespaces).isEmpty }) {
                        selectedAlias = [draft.id]
                    } else {
                        let newAlias = AliasName(appName: "", aliasName: "")
                        aliasNames.append(newAlias)
                        selectedAlias = [newAlias.id]
                    }
                }) {
                    Image(systemName: "plus")
                }

                Button(action: {
                    let removed = aliasNames.filter { selectedAlias.contains($0.id) }
                    aliasNames.removeAll { selectedAlias.contains($0.id) }
                    selectedAlias.removeAll()
                    persistAliases()
                    for alias in removed where !alias.appName.isEmpty {
                        AliasName.trackRemoval(for: alias.appName)
                    }
                }) {
                    Image(systemName: "minus")
                }
                        .disabled(selectedAlias.isEmpty)
            }
                    .buttonStyle(.borderless)
            if let validationMessage {
                Text(validationMessage).font(.caption).foregroundStyle(.orange)
            }
            Table(aliasNames, selection: $selectedAlias, sortOrder: $sortOrder) {
                TableColumn("App Name", value: \.appName) { row in
                    TextField("App Name", text: Binding(
                            get: { row.appName },
                            set: { newValue in
                                if let index = aliasNames.firstIndex(where: { $0.id == row.id }) {
                                    aliasNames[index].appName = newValue
                                    persistAliases()
                                }
                            }
                    ))
                    .help(row.appName)
                }
                TableColumn("Alias Name", value: \.aliasName) { row in
                    TextField("Alias Name", text: Binding(
                            get: { row.aliasName },
                            set: { newValue in
                                if let index = aliasNames.firstIndex(where: { $0.id == row.id }) {
                                    aliasNames[index].aliasName = newValue
                                    persistAliases()
                                }
                            }
                    ))
                    .help(row.aliasName)
                }
            }
                    .onAppear { aliasNames.sort(using: sortOrder) }
                    .onChange(of: sortOrder) {
                        aliasNames.sort(using: $0)
                    }

        }
    }

    private func persistAliases() {
        let entries = aliasNames.filter { !$0.appName.trimmingCharacters(in: .whitespaces).isEmpty }
        guard Set(entries.map(\.appName)).count == entries.count else {
            validationMessage = NSLocalizedString("Each app name must be unique. Rename the duplicate before saving.", comment: "Alias validation")
            return
        }
        validationMessage = nil
        AliasNames.save(entries)
    }
}


