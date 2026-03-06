//
//  ApplicationSettingsView.swift
//  IconChanger
//
//  Created by seril on 7/25/23.
//

import SwiftUI

struct ApplicationSettingsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ApplicationAliasSettingsView()
                    .frame(height: 500) // Occupy majority of space
                
                Divider()
                
                ApplicationFolderSettingsView()
                    .frame(height: 250) // Sufficient space for folders
            }
            .padding()
        }
    }
}
