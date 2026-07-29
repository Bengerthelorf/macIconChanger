import Foundation

private func expect(
    _ condition: @autoclosure () -> Bool,
    _ message: String
) {
    guard condition() else {
        fputs("FAIL: \(message)\n", stderr)
        exit(1)
    }
}

@main
struct IconAppearancePolicyTests {
    static func main() {
        let appPath = "/Applications/Test.app"
        let lightFileName = "11111111-1111-1111-1111-111111111111.png"
        let darkFileName = "22222222-2222-2222-2222-222222222222.png"
        var configuration = AppearanceIconConfiguration(
            appPath: appPath,
            appName: "Test",
            lightIconFileName: lightFileName,
            darkIconFileName: darkFileName,
            lastAppliedAppearance: nil,
            updatedAt: Date()
        )

        expect(
            IconAppearancePolicy.iconFileName(
                for: .light,
                configuration: configuration,
                switchingEnabled: false
            ) == nil,
            "disabled switching must not choose an icon"
        )
        expect(
            IconAppearancePolicy.iconFileName(
                for: .dark,
                configuration: configuration,
                switchingEnabled: true
            ) == darkFileName,
            "complete configuration should choose the current appearance icon"
        )

        configuration.lastAppliedAppearance = .dark
        expect(
            IconAppearancePolicy.iconFileName(
                for: .dark,
                configuration: configuration,
                switchingEnabled: true
            ) == nil,
            "already-applied appearance must not be applied again"
        )

        configuration.lightIconFileName = nil
        configuration.lastAppliedAppearance = nil
        expect(
            IconAppearancePolicy.iconFileName(
                for: .dark,
                configuration: configuration,
                switchingEnabled: true
            ) == nil,
            "incomplete Light/Dark pair must pause switching"
        )

        configuration.lightIconFileName = "../../Documents/private.png"
        expect(
            configuration.fileName(for: .light) == nil && configuration.isEmpty == false,
            "appearance icon paths outside the managed UUID namespace must be rejected"
        )
        configuration.darkIconFileName = "../dark.png"
        expect(
            configuration.isEmpty,
            "configuration with no valid managed icon files must be treated as empty"
        )

        var selection: Set<IconCacheSelectionTarget> = []
        selection = IconAppearancePolicy.toggling(
            .appearance(appPath, .light),
            in: selection
        )
        selection = IconAppearancePolicy.toggling(
            .appearance(appPath, .dark),
            in: selection
        )
        expect(
            selection == [
                .appearance(appPath, .light),
                .appearance(appPath, .dark)
            ],
            "Light and Dark slots should be independently selectable"
        )

        selection = IconAppearancePolicy.toggling(.application(appPath), in: selection)
        expect(
            selection == [.application(appPath)],
            "selecting the application should replace its slot selections"
        )

        selection = IconAppearancePolicy.toggling(
            .appearance(appPath, .light),
            in: selection
        )
        expect(
            selection == [.appearance(appPath, .light)],
            "selecting a slot should replace the whole-application selection"
        )

        var completeConfiguration = configuration
        completeConfiguration.lightIconFileName = lightFileName
        completeConfiguration.darkIconFileName = darkFileName
        expect(
            IconAppearancePolicy.restoreChoice(
                configuration: completeConfiguration,
                normalIconAvailable: true,
                switchingEnabled: true,
                currentAppearance: .dark
            ) == .appearance(.dark),
            "appearance icon should win over normal cache while switching is enabled"
        )
        expect(
            IconAppearancePolicy.restoreChoice(
                configuration: completeConfiguration,
                normalIconAvailable: true,
                switchingEnabled: false,
                currentAppearance: .dark
            ) == .normal,
            "normal cache should be used while appearance switching is disabled"
        )
        expect(
            IconAppearancePolicy.restoreChoice(
                configuration: completeConfiguration,
                normalIconAvailable: false,
                switchingEnabled: false,
                currentAppearance: .dark
            ) == .none,
            "restore should skip apps without an eligible icon"
        )

        expect(
            IconAppearancePolicy.shouldAcknowledgeAppUpdate(
                after: .appearance(.dark),
                hasCachedMetadata: true
            ),
            "appearance restores must advance cached app update metadata"
        )
        expect(
            IconAppearancePolicy.shouldAcknowledgeAppUpdate(
                after: .normal,
                hasCachedMetadata: true
            ),
            "normal restores must advance cached app update metadata"
        )
        expect(
            !IconAppearancePolicy.shouldAcknowledgeAppUpdate(
                after: .none,
                hasCachedMetadata: true
            ),
            "skipped restores must not advance cached app update metadata"
        )

        let permissionMessage = RestoreDefaultErrorPolicy.friendlyMessage(
            "Failed to remove custom icon file: You don’t have permission."
        )
        expect(
            !permissionMessage.localizedCaseInsensitiveContains("closing"),
            "permission failures must not falsely claim that the app is running"
        )

        print("Icon appearance policy tests passed")
    }
}
