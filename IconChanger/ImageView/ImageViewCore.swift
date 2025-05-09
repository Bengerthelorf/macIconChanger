//
//  LocalImageCore.swift
//  IconChanger
//
//  Created by seril on 7/25/23.
//  Modified by Bengerthelorf on 2025/3/21.
//

import SwiftUI
import LaunchPadManagerDBHelper
import QuartzCore

struct ImageViewCore: View {
    @Binding var nsimage: NSImage?
    let setPath: LaunchPadManagerDBHelper.AppInfo
    @State private var isTaskRunning = false
    @State private var task: Task<Void, Never>? = nil
    @Binding var isLoading: Bool

    // Add a new State variable for showing an alert
    @State var showSnackbar = false
    @State var isSuccessful = true
    @State var failureMessage = "Failed to load data."

    // Add an initializer method to ensure backward compatibility
    init(nsimage: Binding<NSImage?>, setPath: LaunchPadManagerDBHelper.AppInfo, isLoading: Binding<Bool> = .constant(true)) {
        self._nsimage = nsimage
        self.setPath = setPath
        self._isLoading = isLoading
    }

    var body: some View {
        Group {
                if let nsimage = nsimage {
                    Image(nsImage: nsimage)
                            .resizable()
                            .scaledToFit()
                            .onTapGesture {
                                changeIcon(image: nsimage)
                            }
                            .onAppear {
                                isLoading = false
                            }
                } else if isLoading {
                    Image("Unknown")
                            .resizable()
                            .scaledToFit()
                            .overlay {
                                ProgressView()
                            }
                            .onAppear {
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                                    if nsimage == nil {
//                                        isLoading = false
//                                    }
//                                }
                                Task { @MainActor in
                                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                                    if nsimage == nil {
                                        isLoading = false
                                    }
                                }
                            }
                } else {
                    VStack {
                        Text("No Icon")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding()
                    }
                    .frame(minWidth: 80, minHeight: 80)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }

            }        .overlay(
                        Group {
                            if showSnackbar {
                                SnackbarView(isPresented: $showSnackbar,
                                             isSuccessful: isSuccessful,
                                             failureMessage: failureMessage
                                ).frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }.ignoresSafeArea()
                )
                    .sheet(isPresented: $isTaskRunning) {
                        VStack {
                            ProgressView() {
                                Text("Changing the icon...")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                            }
                                    .padding(.bottom, 5)
                            Button(action: {
                                task?.cancel()
                                isTaskRunning = false
                            }) {
                                Text("Cancel")
                            }
                        }.padding(20).frame(minWidth: 250, minHeight: 100)
                    }
    }
    func changeIcon(image: NSImage) {
        task = Task {
            do {
                await MainActor.run {
                    isTaskRunning = true
                }
                
                // Create a local copy of the image for memory safety
                let imageCopy = image
                try IconManager.shared.setImage(imageCopy, app: setPath)
                
                await MainActor.run {
                    isTaskRunning = false
                    failureMessage = "Icon changed successfully."
                    isSuccessful = true
                    showSnackbar = true
                }
            } catch {
                await MainActor.run {
                    isTaskRunning = false
                    failureMessage = "Failed to change the icon: \(error.localizedDescription)"
                    isSuccessful = false
                    showSnackbar = true
                }
                print(error)
            }
        }
    }

}


struct SnackbarView: View {
    @Binding var isPresented: Bool
    var isSuccessful: Bool
    var failureMessage: String

    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        Group {
            if isPresented {
                if isSuccessful {
                    GeometryReader { geometry in
                        ZStack {
                            Image(systemName: "checkmark")
                                    .resizable()
                                    .frame(width: 48, height: 48)
                                    .padding()
                                    .background(VisualEffectBlur(material: .underWindowBackground, blendingMode: .withinWindow))
                                    .cornerRadius(10)
                                    .foregroundColor(Color(red: 0.24, green: 0.70, blue: 0.44)) // Light green
                                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        }
                                .onAppear(perform: {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation {
                                            isPresented = false
                                        }
                                    }
                                })
                    }
                } else {
                    EmptyView()
                            .onAppear(perform: {
                                showAlert = true
                                alertMessage = failureMessage
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        isPresented = false
                                    }
                                }
                            })
                }
            } else {
                EmptyView()
            }
        }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
    }
}

struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
