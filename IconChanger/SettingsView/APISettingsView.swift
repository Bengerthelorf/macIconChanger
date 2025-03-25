//
//  APISettingsView.swift
//  IconChanger
//
//  Created by seril on 7/25/23.
//  Modified by Bengerthelorf on 2025/3/21.
//

import SwiftUI

struct APISettingsView: View {
    @AppStorage("apiKey") var apiKey: String = ""
    @State private var isTestingAPI = false
    @State private var testResult: String? = nil
    @State private var testSuccess = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title Section
            HStack {
                Image(systemName: "bolt")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text(NSLocalizedString("API", comment: "Settings tab"))
                    .font(.title2)
                    .fontWeight(.medium)
            }
            .padding(.top, 10)
            .padding(.bottom, 5)
            
            // API Key Input Section
            VStack(alignment: .leading, spacing: 8) {
                Text(NSLocalizedString("API Key: ", comment: "API settings"))
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextField("", text: $apiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                
                Text(NSLocalizedString("You need to obtain an API key from macosicons.com", comment: "API settings instruction"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 5)
            
            Divider()
                .padding(.vertical, 5)
            
            // Test Button Section
            VStack(alignment: .leading, spacing: 12) {
                Button {
                    if (!isTestingAPI && !apiKey.isEmpty) {
                        isTestingAPI = true
                        testResult = nil
                        
                        // Create task to avoid modifying state directly
                        Task {
                            await testAPI()
                        }
                    }
                } label: {
                    HStack {
                        if isTestingAPI {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text(NSLocalizedString("Testing...", comment: "API testing status"))
                                .padding(.leading, 8)
                        } else {
                            Image(systemName: "network")
                                .font(.body)
                            Text(NSLocalizedString("Test API Connection", comment: "API settings button"))
                                .padding(.leading, 4)
                        }
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(apiKey.isEmpty || isTestingAPI ? Color.gray.opacity(0.3) : Color.blue.opacity(0.2))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(apiKey.isEmpty || isTestingAPI)
                
                if let result = testResult {
                    HStack(spacing: 8) {
                        Image(systemName: testSuccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundColor(testSuccess ? .green : .red)
                        Text(result)
                            .font(.callout)
                            .foregroundColor(testSuccess ? .green : .red)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(Color(testSuccess ? NSColor.systemGreen.withAlphaComponent(0.1) : NSColor.systemRed.withAlphaComponent(0.1)))
                    .cornerRadius(6)
                }
            }
            .padding(.horizontal, 5)
            
            Spacer()
        }
        .padding()
        .background(Color(NSColor.textBackgroundColor).opacity(0.5))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func testAPI() async {
        // Already executing in a Task, so we don't need to create another one
        let testController = MyQueryRequestController()
        
        do {
            let results = try await testController.sendRequest("Chrome")
            
            // Update UI state on the main thread
            await MainActor.run {
                if results.isEmpty {
                    testResult = NSLocalizedString("API connection established but no results returned.", comment: "API testing result")
                    testSuccess = false
                } else {
                    testResult = String(format: NSLocalizedString("API connection successful! Found %@ icons.", comment: "API testing result"), String(results.count))
                    testSuccess = true
                }
                isTestingAPI = false
            }
        } catch {
            // Update UI state on the main thread
            await MainActor.run {
                testResult = String(format: NSLocalizedString("API test failed: %@", comment: "API testing error"), error.localizedDescription)
                testSuccess = false
                isTestingAPI = false
            }
        }
    }
}

