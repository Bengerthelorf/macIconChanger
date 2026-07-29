import Foundation

@main
enum DiagnosticsLoggingTests {
  static func main() throws {
    let fm = FileManager.default
    let root = URL(fileURLWithPath: NSTemporaryDirectory())
      .appendingPathComponent("iconchanger-diagnostics-\(UUID().uuidString)")
    try fm.createDirectory(at: root, withIntermediateDirectories: true)
    defer { try? fm.removeItem(at: root) }

    let suiteName = "IconChanger.DiagnosticsTests.\(UUID().uuidString)"
    guard let defaults = UserDefaults(suiteName: suiteName) else {
      fatalError("Could not create isolated UserDefaults suite")
    }
    defer { defaults.removePersistentDomain(forName: suiteName) }

    defaults.set(true, forKey: "t2e")
    let logger = DiagnosticsLogger(
      defaults: defaults,
      directory: root,
      maxFileSize: 700,
      retainedFiles: 2
    )
    let logURL = root.appendingPathComponent("diagnostics.log")
    let context = DiagnosticsContext(
      operation: .restore,
      appName: "Example",
      appPath: "/Applications/Example.app",
      iconKind: "cached_normal",
      iconPath: "/private/cache/example.png"
    )

    logger.log(.operation, phase: "restore.start", context: context)
    logger.flush()
    assertFalse(fm.fileExists(atPath: logURL.path), "master switch must default to off")

    defaults.set(true, forKey: DiagnosticsSettings.enabled)
    logger.log(.operation, phase: "restore.completed", context: context)
    logger.flush()

    var entries = try readEntries(logURL)
    assertEqual(entries.count, 1, "enabled logger should write one JSON line")
    assertEqual(
      entries[0]["app_path"] as? String, "/Applications/Example.app",
      "app paths should default to on")
    assertEqual(
      entries[0]["app_name"] as? String, "Example",
      "app names should default to on")
    assertNil(entries[0]["icon_kind"], "icon details should default to off")
    assertNil(entries[0]["icon_path"], "icon paths must default to off")

    defaults.set(true, forKey: DiagnosticsSettings.includeIconDetails)
    logger.log(.step, phase: "restore.icon_selected", context: context)
    logger.flush()
    entries = try readEntries(logURL)
    assertEqual(
      entries.last?["icon_kind"] as? String, "cached_normal",
      "icon kind should be independently selectable")
    assertNil(entries.last?["icon_path"], "full icon path should remain independently disabled")

    defaults.set(true, forKey: DiagnosticsSettings.includeIconPaths)
    logger.log(.step, phase: "restore.icon_selected", context: context)
    logger.flush()
    entries = try readEntries(logURL)
    assertEqual(
      entries.last?["icon_path"] as? String, "/private/cache/example.png",
      "icon paths should be recorded only after explicit opt-in")

    defaults.set(false, forKey: DiagnosticsSettings.includeAppNames)
    defaults.set(false, forKey: DiagnosticsSettings.includeAppPaths)
    logger.log(
      .failure,
      phase: "privacy.defaults",
      context: context,
      details: [
        "error_message": "Could not access /Applications/Example.app",
        "process_stderr": "secret helper output",
        "system_os_version": "testOS",
      ]
    )
    logger.flush()
    entries = try readEntries(logURL)
    let privacyEntry = entries.last!
    assertNil(privacyEntry["app_name"], "app names should be independently suppressible")
    assertNil(privacyEntry["app_path"], "app paths should be independently suppressible")
    let privacyDetails = privacyEntry["details"] as? [String: String]
    assertEqual(
      privacyDetails?["error_message"],
      "Could not access <redacted-app-path>",
      "enabled error messages should redact a disabled app path")
    assertNil(
      privacyDetails?["process_stderr"],
      "helper output must default to off")
    assertEqual(
      privacyDetails?["system_os_version"], "testOS",
      "system information should default to on")

    defaults.set(false, forKey: DiagnosticsSettings.includeErrorMessages)
    defaults.set(false, forKey: DiagnosticsSettings.includeSystemInfo)
    defaults.set(true, forKey: DiagnosticsSettings.includeProcessOutput)
    logger.log(
      .failure,
      phase: "privacy.customized",
      context: context,
      details: [
        "error_message": "hidden error",
        "process_stderr": "visible helper output",
        "system_os_version": "hiddenOS",
      ]
    )
    logger.flush()
    entries = try readEntries(logURL)
    let customizedDetails = entries.last?["details"] as? [String: String]
    assertNil(customizedDetails?["error_message"], "error text switch should suppress messages")
    assertEqual(
      customizedDetails?["process_stderr"], "visible helper output",
      "helper output should require explicit opt-in")
    assertNil(
      customizedDetails?["system_os_version"],
      "system information switch should suppress environment fields")

    let beforeDisabledCategory = totalEntryCount(in: root)
    defaults.set(false, forKey: DiagnosticsSettings.recordRestore)
    logger.log(.operation, phase: "restore.suppressed", context: context)
    logger.flush()
    assertEqual(
      totalEntryCount(in: root), beforeDisabledCategory,
      "restore category switch should suppress restore events")

    defaults.set(false, forKey: DiagnosticsSettings.recordSetup)
    let beforeDisabledSetup = totalEntryCount(in: root)
    logger.log(
      .operation,
      phase: "setup.suppressed",
      context: DiagnosticsContext(operation: .setup)
    )
    logger.flush()
    assertEqual(
      totalEntryCount(in: root), beforeDisabledSetup,
      "setup category switch should suppress setup events")

    defaults.set(true, forKey: DiagnosticsSettings.recordRestore)
    defaults.set(false, forKey: DiagnosticsSettings.recordSteps)
    let beforeDisabledSteps = totalEntryCount(in: root)
    logger.log(.step, phase: "step.suppressed", context: context)
    logger.flush()
    assertEqual(
      totalEntryCount(in: root), beforeDisabledSteps, "step switch should suppress step events")

    defaults.set(false, forKey: "t2e")
    let beforeDeveloperModeOff = totalEntryCount(in: root)
    logger.log(.operation, phase: "developer_mode.suppressed", context: context)
    logger.flush()
    assertEqual(
      totalEntryCount(in: root), beforeDeveloperModeOff, "developer mode off must stop diagnostics")

    defaults.set(true, forKey: "t2e")
    defaults.set(true, forKey: DiagnosticsSettings.recordSteps)
    let payload = String(repeating: "x", count: 300)
    for index in 0..<8 {
      logger.log(
        .operation,
        phase: "rotation.\(index)",
        context: context,
        details: ["payload": payload]
      )
    }
    logger.flush()

    assertTrue(
      fm.fileExists(atPath: root.appendingPathComponent("diagnostics.log.1").path),
      "log should rotate when it reaches the configured limit"
    )
    let permissions = try fm.attributesOfItem(atPath: logURL.path)[.posixPermissions] as? NSNumber
    assertEqual(
      (permissions?.intValue ?? 0) & 0o777,
      0o600,
      "diagnostics log must be private to the current user"
    )

    logger.clear()
    assertFalse(fm.fileExists(atPath: logURL.path), "clear should remove the current log")
    assertFalse(
      fm.fileExists(atPath: root.appendingPathComponent("diagnostics.log.1").path),
      "clear should remove rotated logs"
    )

    print("PASS: diagnostics logging is configurable, private, structured, and rotated")
  }

  private static func readEntries(_ url: URL) throws -> [[String: Any]] {
    let text = try String(contentsOf: url, encoding: .utf8)
    return try text.split(separator: "\n").map { line in
      let data = Data(line.utf8)
      guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        throw NSError(domain: "DiagnosticsTests", code: 1)
      }
      return object
    }
  }

  private static func totalEntryCount(in root: URL) -> Int {
    (0...2).reduce(0) { count, index in
      let name = index == 0 ? "diagnostics.log" : "diagnostics.log.\(index)"
      let url = root.appendingPathComponent(name)
      guard let text = try? String(contentsOf: url, encoding: .utf8) else {
        return count
      }
      return count + text.split(separator: "\n").count
    }
  }

  private static func assertTrue(
    _ value: @autoclosure () -> Bool,
    _ message: String
  ) {
    if !value() {
      fatalError("Assertion failed: \(message)")
    }
  }

  private static func assertFalse(
    _ value: @autoclosure () -> Bool,
    _ message: String
  ) {
    assertTrue(!value(), message)
  }

  private static func assertNil(
    _ value: @autoclosure () -> Any?,
    _ message: String
  ) {
    if value() != nil {
      fatalError("Assertion failed: \(message)")
    }
  }

  private static func assertEqual<T: Equatable>(
    _ actual: @autoclosure () -> T,
    _ expected: T,
    _ message: String
  ) {
    let actualValue = actual()
    if actualValue != expected {
      fatalError(
        "Assertion failed: \(message). Expected \(expected), got \(actualValue)"
      )
    }
  }
}
