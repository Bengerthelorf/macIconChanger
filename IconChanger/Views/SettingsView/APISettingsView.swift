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
        Form {
            Section {
                TextField(NSLocalizedString("API Key: ", comment: "API settings"), text: $apiKey)
            } header: {
                Label(NSLocalizedString("API Key", comment: "Settings section"), systemImage: "key")
            } footer: {
                Text(NSLocalizedString("You need to obtain an API key from macosicons.com", comment: "API settings instruction"))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Section {
                HStack(spacing: 10) {
                    Button {
                        if !isTestingAPI && !apiKey.isEmpty {
                            isTestingAPI = true
                            testResult = nil
                            Task { await testAPI() }
                        }
                    } label: {
                        if isTestingAPI {
                            HStack(spacing: 6) {
                                ProgressView()
                                    .controlSize(.small)
                                Text(NSLocalizedString("Testing...", comment: "API testing status"))
                            }
                        } else {
                            Text(NSLocalizedString("Test API Connection", comment: "API settings button"))
                        }
                    }
                    .disabled(apiKey.isEmpty || isTestingAPI)

                    if let result = testResult {
                        Spacer()
                        Label(result, systemImage: testSuccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .font(.callout)
                            .foregroundColor(testSuccess ? .green : .red)
                    }
                }
            } header: {
                Label(NSLocalizedString("Connection Test", comment: "Settings section"), systemImage: "network")
            }
        }
        .formStyle(.grouped)
    }

    func testAPI() async {
        let testController = MyQueryRequestController()

        do {
            let result = try await testController.testAPIConnection()

            await MainActor.run {
                if result.iconCount == 0 {
                    testResult = NSLocalizedString("API connection established but no results returned.", comment: "API testing result")
                } else {
                    testResult = String(format: NSLocalizedString("API connection successful!", comment: "API testing result"), String(result.iconCount))
                }
                testSuccess = true
                isTestingAPI = false
            }
        } catch {
            await MainActor.run {
                let errorMessage = extractErrorMessage(from: error)
                testResult = String(format: NSLocalizedString("API test failed: %@", comment: "API testing error"), errorMessage)
                testSuccess = false
                isTestingAPI = false
            }
        }
    }

    private func extractErrorMessage(from error: Error) -> String {
        let errorDescription = error.localizedDescription

        if errorDescription.contains("API error:") {
            if let messageStart = errorDescription.range(of: "\"message\":\""),
               let messageEnd = errorDescription.range(of: "\"}", options: [], range: messageStart.upperBound..<errorDescription.endIndex) {
                return String(errorDescription[messageStart.upperBound..<messageEnd.lowerBound])
            }
        }

        return errorDescription
    }
}
