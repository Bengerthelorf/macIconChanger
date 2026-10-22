//
//  LocalImageCore.swift
//  IconChanger
//

import SwiftUI
import LaunchPadManagerDBHelper
import QuartzCore

struct ImageViewCore: View {
    @Binding var nsimage: NSImage?
    let setPath: AppItem
    @State private var showPreview = false
    @Binding var isLoading: Bool
    let applicationSource: IconApplicationSource
    let iconDescription: String

    init(
        nsimage: Binding<NSImage?>,
        setPath: AppItem,
        isLoading: Binding<Bool> = .constant(true),
        applicationSource: IconApplicationSource = .local,
        iconDescription: String = ""
    ) {
        self._nsimage = nsimage
        self.setPath = setPath
        self._isLoading = isLoading
        self.applicationSource = applicationSource
        self.iconDescription = iconDescription
    }

    var body: some View {
        Group {
            if let image = nsimage {
                Button { showPreview = true } label: {
                    Image(nsImage: image).resizable().scaledToFit()
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help("Preview this icon before applying it")
                .accessibilityLabel(Text(iconDescription.isEmpty
                    ? String(format: NSLocalizedString("Preview icon for %@", comment: "Icon button"), setPath.name)
                    : iconDescription))
                .accessibilityHint("Opens a preview. Your icon will not change until you choose Apply.")
            } else if isLoading {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityLabel("Loading icon")
            } else {
                Label("No Icon", systemImage: "photo")
                    .font(.caption).foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
            }
        }
        .sheet(isPresented: $showPreview) {
            if let image = nsimage {
                IconApplicationPreview(image: image, app: setPath, source: applicationSource)
            }
        }
    }
}

/// All input routes share the same preview and explicit application action.
struct IconApplicationPreview: View {
    let image: NSImage
    let app: AppItem
    var source: IconApplicationSource = .local
    @Environment(\.dismiss) private var dismiss
    @State private var isApplying = false
    @State private var didApply = false
    @State private var errorMessage: String?
    @State private var snapshot: IconUndoSnapshot?

    var body: some View {
        VStack(spacing: 20) {
            Text(app.name).font(.title2.bold()).lineLimit(2)
            HStack(spacing: 32) {
                VStack(spacing: 8) {
                    Image(nsImage: snapshot?.image ?? NSWorkspace.shared.icon(forFile: app.url.path))
                        .resizable().scaledToFit().frame(width: 96, height: 96)
                    Text("Current").foregroundStyle(.secondary)
                }
                Image(systemName: "arrow.right").foregroundStyle(.secondary)
                VStack(spacing: 8) {
                    Image(nsImage: image).resizable().scaledToFit().frame(width: 96, height: 96)
                    Text("Selected").foregroundStyle(.secondary)
                }
            }
            Text(didApply ? "Icon applied successfully." : "Preview only. Choose Apply to change this icon.")
                .font(.callout).foregroundStyle(.secondary)
            if let errorMessage {
                Text(errorMessage).foregroundStyle(.red).font(.callout)
                    .textSelection(.enabled).fixedSize(horizontal: false, vertical: true)
            }
            if isApplying {
                ProgressView("Applying icon…")
                Text("Please wait for the current operation to finish.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            HStack {
                Button(didApply ? "Done" : "Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                if didApply, snapshot != nil {
                    Button("Undo") { apply(undo: true) }
                }
                Spacer()
                if !didApply {
                    Button("Apply Icon") { apply(undo: false) }
                        .keyboardShortcut(.defaultAction)
                        .buttonStyle(.borderedProminent)
                }
            }
            .disabled(isApplying)
        }
        .padding(24)
        .frame(width: 420)
        .interactiveDismissDisabled(isApplying)
    }

    private func apply(undo: Bool) {
        guard !isApplying else { return }
        isApplying = true
        errorMessage = nil
        if !undo { snapshot = IconManager.shared.captureUndoSnapshot(for: app) }
        let original = snapshot
        Task {
            do {
                try await Task.detached(priority: .userInitiated) {
                    if undo, let original {
                        try IconManager.shared.restoreUndoSnapshot(original, app: app)
                    } else {
                        try IconManager.shared.setImage(image, app: app, source: source)
                    }
                }.value
                didApply = !undo
                if undo { snapshot = nil }
            } catch {
                errorMessage = (error as NSError).domain == "IconChanger.UIReview"
                    ? error.localizedDescription
                    : ChangeView.friendlyErrorMessage(error.localizedDescription, appPath: app.id)
            }
            isApplying = false
        }
    }
}

struct AppearanceIconContextMenuItems: View {
    let image: NSImage?
    let app: AppItem

    var body: some View {
        ForEach(IconAppearance.allCases, id: \.self) { appearance in
            Button {
                assign(appearance)
            } label: {
                Label(
                    String(
                        format: NSLocalizedString(
                            "Set as %@ Icon",
                            comment: "Context menu action for assigning a light or dark icon"
                        ),
                        appearance.displayName
                    ),
                    systemImage: appearance.systemImage
                )
            }
            .disabled(image == nil)
        }
    }

    private func assign(_ appearance: IconAppearance) {
        guard let imageCopy = image?.copy() as? NSImage else { return }
        Task { @MainActor in
            do {
                try await IconAppearanceSwitchService.shared.assign(
                    image: imageCopy,
                    app: app,
                    appearance: appearance
                )
            } catch {
                let alert = NSAlert()
                alert.alertStyle = .critical
                alert.messageText = NSLocalizedString(
                    "Unable to Save Appearance Icon",
                    comment: "Appearance icon assignment error title"
                )
                alert.informativeText = error.localizedDescription
                alert.addButton(withTitle: NSLocalizedString("OK", comment: "Alert button"))
                alert.runModal()
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
