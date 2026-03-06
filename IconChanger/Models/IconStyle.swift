//
//  IconStyle.swift
//  IconChanger
//
//  Created by CantonMonkey on 10/10/2025.
//


import Foundation


enum IconStyle: String, CaseIterable, Identifiable {
    case all = "All Icons"
    case liquidGlass = "Liquid Glass"

    // case classic = "Classic"
    // case minimal = "Minimal"
    // case colorful = "Colorful"

    var id: String { self.rawValue }


    var filterQuery: String? {
        switch self {
        case .all:
            return nil  // return all categories
        case .liquidGlass:
            return "isLiquidGlass = true"
        //scalable
        // case .classic:
        //     return "isClassic = true"
        }
    }

    /// category name display
    var displayName: String {
        return self.rawValue
    }
}
