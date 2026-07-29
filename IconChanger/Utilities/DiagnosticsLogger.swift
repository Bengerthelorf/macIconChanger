//
//  DiagnosticsLogger.swift
//  IconChanger
//

import Foundation

enum DiagnosticsOperation: String, CaseIterable {
  case replace
  case restore
  case remove
  case appearance
  case setup
  case permission
  case background
  case discovery
  case cache
  case network
}

enum DiagnosticsEventKind: String {
  case operation
  case step
  case performance
  case failure
  case skipped
}

enum DiagnosticsSource: String {
  case manual
  case scheduled
  case appUpdate = "app_update"
  case appearanceChange = "appearance_change"
  case startup
  case system
}

struct DiagnosticsContext {
  let operation: DiagnosticsOperation
  let operationID: UUID
  let batchID: UUID?
  let source: DiagnosticsSource
  let appName: String?
  let appPath: String?
  let iconKind: String?
  let iconPath: String?

  init(
    operation: DiagnosticsOperation,
    operationID: UUID = UUID(),
    batchID: UUID? = nil,
    source: DiagnosticsSource = .manual,
    appName: String? = nil,
    appPath: String? = nil,
    iconKind: String? = nil,
    iconPath: String? = nil
  ) {
    self.operation = operation
    self.operationID = operationID
    self.batchID = batchID
    self.source = source
    self.appName = appName
    self.appPath = appPath
    self.iconKind = iconKind
    self.iconPath = iconPath
  }

  func withIcon(kind: String?, path: String?) -> DiagnosticsContext {
    DiagnosticsContext(
      operation: operation,
      operationID: operationID,
      batchID: batchID,
      source: source,
      appName: appName,
      appPath: appPath,
      iconKind: kind,
      iconPath: path
    )
  }
}

struct DiagnosticsTimer {
  private let startedAt = DispatchTime.now().uptimeNanoseconds

  var elapsedMilliseconds: Double {
    let elapsed = DispatchTime.now().uptimeNanoseconds - startedAt
    return Double(elapsed) / 1_000_000
  }
}

enum DiagnosticsSettings {
  static let enabled = "diagnosticsEnabled"
  static let recordReplace = "diagnosticsRecordReplace"
  static let recordRestore = "diagnosticsRecordRestore"
  static let recordRemove = "diagnosticsRecordRemove"
  static let recordAppearance = "diagnosticsRecordAppearance"
  static let recordSetup = "diagnosticsRecordSetup"
  static let recordPermission = "diagnosticsRecordPermission"
  static let recordBackground = "diagnosticsRecordBackground"
  static let recordDiscovery = "diagnosticsRecordDiscovery"
  static let recordCache = "diagnosticsRecordCache"
  static let recordNetwork = "diagnosticsRecordNetwork"
  static let recordSteps = "diagnosticsRecordSteps"
  static let recordPerformance = "diagnosticsRecordPerformance"
  static let recordFailures = "diagnosticsRecordFailures"
  static let recordSkipped = "diagnosticsRecordSkipped"
  static let includeAppNames = "diagnosticsIncludeAppNames"
  static let includeAppPaths = "diagnosticsIncludeAppPaths"
  static let includeIconDetails = "diagnosticsIncludeIconDetails"
  static let includeIconPaths = "diagnosticsIncludeIconPaths"
  static let includeErrorMessages = "diagnosticsIncludeErrorMessages"
  static let includeProcessOutput = "diagnosticsIncludeProcessOutput"
  static let includeSystemInfo = "diagnosticsIncludeSystemInfo"

  static let defaults: [String: Bool] = [
    enabled: false,
    recordReplace: true,
    recordRestore: true,
    recordRemove: true,
    recordAppearance: true,
    recordSetup: true,
    recordPermission: true,
    recordBackground: true,
    recordDiscovery: true,
    recordCache: true,
    recordNetwork: true,
    recordSteps: true,
    recordPerformance: true,
    recordFailures: true,
    recordSkipped: true,
    includeAppNames: true,
    includeAppPaths: true,
    includeIconDetails: false,
    includeIconPaths: false,
    includeErrorMessages: true,
    includeProcessOutput: false,
    includeSystemInfo: true,
  ]

  static func register(in defaults: UserDefaults = .standard) {
    defaults.register(defaults: Self.defaults)
  }
}

final class DiagnosticsLogger {
  static let shared = DiagnosticsLogger()

  static var logURL: URL {
    AppPaths.applicationSupportRoot.appendingPathComponent("diagnostics.log")
  }

  private let defaults: UserDefaults
  private let fileManager: FileManager
  private let logURL: URL
  private let maxFileSize: UInt64
  private let retainedFiles: Int
  private let queue = DispatchQueue(label: "com.zhuhaoyu.IconChanger.diagnostics")

  init(
    defaults: UserDefaults = .standard,
    directory: URL = AppPaths.applicationSupportRoot,
    fileManager: FileManager = .default,
    maxFileSize: UInt64 = 5 * 1_024 * 1_024,
    retainedFiles: Int = 3
  ) {
    self.defaults = defaults
    self.fileManager = fileManager
    self.logURL = directory.appendingPathComponent("diagnostics.log")
    self.maxFileSize = maxFileSize
    self.retainedFiles = max(1, retainedFiles)
    DiagnosticsSettings.register(in: defaults)
  }

  static func errorDetails(_ error: Error) -> [String: String] {
    let nsError = error as NSError
    return [
      "error_domain": nsError.domain,
      "error_code": String(nsError.code),
      "error_message": error.localizedDescription,
    ]
  }

  func log(
    _ kind: DiagnosticsEventKind,
    phase: String,
    context: DiagnosticsContext,
    durationMilliseconds: Double? = nil,
    details: [String: String] = [:]
  ) {
    guard shouldRecord(kind: kind, operation: context.operation) else { return }

    var entry: [String: Any] = [
      "timestamp": ISO8601DateFormatter().string(from: Date()),
      "event": kind.rawValue,
      "phase": phase,
      "operation": context.operation.rawValue,
      "operation_id": context.operationID.uuidString,
      "source": context.source.rawValue,
    ]

    if let batchID = context.batchID {
      entry["batch_id"] = batchID.uuidString
    }
    if setting(DiagnosticsSettings.includeAppNames), let appName = context.appName {
      entry["app_name"] = appName
    }
    if setting(DiagnosticsSettings.includeAppPaths), let appPath = context.appPath {
      entry["app_path"] = appPath
    }
    if setting(DiagnosticsSettings.includeIconDetails), let iconKind = context.iconKind {
      entry["icon_kind"] = iconKind
    }
    if setting(DiagnosticsSettings.includeIconDetails),
      setting(DiagnosticsSettings.includeIconPaths),
      let iconPath = context.iconPath
    {
      entry["icon_path"] = iconPath
    }
    if let durationMilliseconds {
      entry["duration_ms"] = (durationMilliseconds * 100).rounded() / 100
    }
    if !details.isEmpty {
      var filteredDetails = details
      if !setting(DiagnosticsSettings.includeErrorMessages) {
        filteredDetails = filteredDetails.filter { $0.key != "error_message" }
      }
      if !setting(DiagnosticsSettings.includeProcessOutput) {
        filteredDetails = filteredDetails.filter { !$0.key.hasPrefix("process_") }
      }
      if !setting(DiagnosticsSettings.includeSystemInfo) {
        filteredDetails = filteredDetails.filter { !$0.key.hasPrefix("system_") }
      }
      if !setting(DiagnosticsSettings.includeAppPaths),
        let appPath = context.appPath
      {
        filteredDetails = filteredDetails.mapValues {
          $0.replacingOccurrences(
            of: appPath,
            with: "<redacted-app-path>"
          )
        }
      }
      if !setting(DiagnosticsSettings.includeAppPaths) {
        let homePath = fileManager.homeDirectoryForCurrentUser.path
        filteredDetails = filteredDetails.mapValues {
          $0.replacingOccurrences(of: homePath, with: "~")
        }
      }
      if !setting(DiagnosticsSettings.includeIconPaths),
        let iconPath = context.iconPath
      {
        filteredDetails = filteredDetails.mapValues {
          $0.replacingOccurrences(
            of: iconPath,
            with: "<redacted-icon-path>"
          )
        }
      }
      entry["details"] = filteredDetails
    }

    queue.async { [weak self] in
      self?.append(entry)
    }
  }

  func flush() {
    queue.sync {}
  }

  func clear() {
    queue.sync {
      try? fileManager.removeItem(at: logURL)
      for index in 1...retainedFiles {
        try? fileManager.removeItem(at: rotatedURL(index))
      }
    }
  }

  func fileSizeDescription() -> String {
    queue.sync {
      guard let attributes = try? fileManager.attributesOfItem(atPath: logURL.path),
        let size = attributes[.size] as? NSNumber
      else {
        return "No log file yet"
      }
      return ByteCountFormatter.string(
        fromByteCount: size.int64Value,
        countStyle: .file
      )
    }
  }

  private func shouldRecord(
    kind: DiagnosticsEventKind,
    operation: DiagnosticsOperation
  ) -> Bool {
    guard defaults.bool(forKey: "t2e"),
      setting(DiagnosticsSettings.enabled)
    else {
      return false
    }

    let operationEnabled: Bool
    switch operation {
    case .replace:
      operationEnabled = setting(DiagnosticsSettings.recordReplace)
    case .restore:
      operationEnabled = setting(DiagnosticsSettings.recordRestore)
    case .remove:
      operationEnabled = setting(DiagnosticsSettings.recordRemove)
    case .appearance:
      operationEnabled = setting(DiagnosticsSettings.recordAppearance)
    case .setup:
      operationEnabled = setting(DiagnosticsSettings.recordSetup)
    case .permission:
      operationEnabled = setting(DiagnosticsSettings.recordPermission)
    case .background:
      operationEnabled = setting(DiagnosticsSettings.recordBackground)
    case .discovery:
      operationEnabled = setting(DiagnosticsSettings.recordDiscovery)
    case .cache:
      operationEnabled = setting(DiagnosticsSettings.recordCache)
    case .network:
      operationEnabled = setting(DiagnosticsSettings.recordNetwork)
    }
    guard operationEnabled else { return false }

    switch kind {
    case .operation:
      return true
    case .step:
      return setting(DiagnosticsSettings.recordSteps)
    case .performance:
      return setting(DiagnosticsSettings.recordPerformance)
    case .failure:
      return setting(DiagnosticsSettings.recordFailures)
    case .skipped:
      return setting(DiagnosticsSettings.recordSkipped)
    }
  }

  private func setting(_ key: String) -> Bool {
    if defaults.object(forKey: key) == nil {
      return DiagnosticsSettings.defaults[key] ?? false
    }
    return defaults.bool(forKey: key)
  }

  private func append(_ entry: [String: Any]) {
    do {
      let directory = logURL.deletingLastPathComponent()
      try fileManager.createDirectory(
        at: directory,
        withIntermediateDirectories: true
      )

      let data = try JSONSerialization.data(
        withJSONObject: entry,
        options: [.sortedKeys]
      )
      try rotateIfNeeded(adding: UInt64(data.count + 1))

      if !fileManager.fileExists(atPath: logURL.path) {
        _ = fileManager.createFile(
          atPath: logURL.path,
          contents: nil,
          attributes: [.posixPermissions: 0o600]
        )
      }

      let handle = try FileHandle(forWritingTo: logURL)
      try handle.seekToEnd()
      try handle.write(contentsOf: data)
      try handle.write(contentsOf: Data([0x0A]))
      try handle.close()
      try? fileManager.setAttributes(
        [.posixPermissions: 0o600],
        ofItemAtPath: logURL.path
      )
    } catch {
      // Diagnostics must never make an icon operation fail.
    }
  }

  private func rotateIfNeeded(adding bytes: UInt64) throws {
    let currentSize =
      (try? fileManager.attributesOfItem(atPath: logURL.path)[.size] as? NSNumber)?.uint64Value ?? 0
    guard currentSize > 0, currentSize + bytes > maxFileSize else { return }

    try? fileManager.removeItem(at: rotatedURL(retainedFiles))
    if retainedFiles > 1 {
      for index in stride(from: retainedFiles - 1, through: 1, by: -1) {
        let source = rotatedURL(index)
        guard fileManager.fileExists(atPath: source.path) else { continue }
        try fileManager.moveItem(at: source, to: rotatedURL(index + 1))
      }
    }
    if fileManager.fileExists(atPath: logURL.path) {
      try fileManager.moveItem(at: logURL, to: rotatedURL(1))
    }
  }

  private func rotatedURL(_ index: Int) -> URL {
    logURL.deletingLastPathComponent()
      .appendingPathComponent("diagnostics.log.\(index)")
  }
}
