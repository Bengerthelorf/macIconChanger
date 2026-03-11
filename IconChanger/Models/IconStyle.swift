//
//  IconStyle.swift
//  IconChanger
//

import Foundation

enum IconStyle: String, CaseIterable, Identifiable {
    case all = "All Icons"
    case liquidGlass = "Liquid Glass"

    var id: String { self.rawValue }

    var filterQuery: String? {
        switch self {
        case .all:
            return nil
        case .liquidGlass:
            return "isLiquidGlass = true"
        }
    }

    var displayName: String {
        return NSLocalizedString(self.rawValue, comment: "Icon style name")
    }
}
