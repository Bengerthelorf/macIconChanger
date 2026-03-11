//
//  ApplicationSettingsView.swift
//  IconChanger
//

import SwiftUI

struct ApplicationSettingsView: View {
    var body: some View {
        VStack(spacing: 0) {
            ApplicationAliasSettingsView()
                .padding([.horizontal, .top])

            ApplicationFolderSettingsView()
                .frame(height: 110)
                .padding([.horizontal, .bottom])
        }
    }
}
