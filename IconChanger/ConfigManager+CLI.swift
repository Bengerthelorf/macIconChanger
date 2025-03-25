//
//  ConfigManager+CLI.swift
//  IconChanger
//
//  Created by Zane on 3/26/25.
//

import Foundation

extension ConfigManager {
    // 导出配置并保存最新版本以供CLI使用
    func exportConfigurationForCLI() -> URL? {
        // 导出配置
        if let exportUrl = exportConfiguration() {
            // 将副本保存到共享目录供CLI使用
            let sharedConfigDir = getSharedConfigDirectory()
            let latestExportFile = sharedConfigDir.appendingPathComponent("latest_export.json")
            
            do {
                let data = try Data(contentsOf: exportUrl)
                try data.write(to: latestExportFile)
                return exportUrl
            } catch {
                print("Error saving for CLI: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    // 检查并应用通过CLI导入的配置
    func checkForCLIImports() {
        let sharedConfigDir = getSharedConfigDirectory()
        let flagFile = sharedConfigDir.appendingPathComponent("pending_import")
        let importedFile = sharedConfigDir.appendingPathComponent("imported_config.json")
        
        // 如果存在导入标志，处理导入的配置
        if FileManager.default.fileExists(atPath: flagFile.path) &&
           FileManager.default.fileExists(atPath: importedFile.path) {
            
            do {
                // 导入配置
                let result = importConfiguration(from: importedFile)
                print("CLI Import completed: \(result.aliases) aliases and \(result.icons) icons imported")
                
                // 删除标志文件
                try FileManager.default.removeItem(at: flagFile)
            } catch {
                print("Error processing CLI import: \(error.localizedDescription)")
            }
        }
    }
    
    // 获取共享配置目录
    private func getSharedConfigDirectory() -> URL {
        let path = "\(NSHomeDirectory())/.iconchanger/config"
        let url = URL(fileURLWithPath: path)
        
        if !FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
        
        return url
    }
}
