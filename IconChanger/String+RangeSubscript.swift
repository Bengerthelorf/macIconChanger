//
//  String+RangeSubscript.swift
//  Endless (FileProvider iOS)
//
//  Created by 朱浩宇 on 2022/1/10.
//

import Foundation

extension String {
    subscript(range: ClosedRange<Int>) -> String? {
        guard range.lowerBound >= 0, range.upperBound < count else { return nil }
        return String(self[index(startIndex, offsetBy: range.lowerBound)...index(startIndex, offsetBy: range.upperBound)])
    }

    subscript(range: Range<Int>) -> String? {
        guard range.lowerBound >= 0, range.upperBound <= count, !range.isEmpty else { return nil }
        return String(self[index(startIndex, offsetBy: range.lowerBound)...index(startIndex, offsetBy: range.upperBound - 1)])
    }

    subscript(i: Int) -> String? {
        guard i >= 0, i < count else { return nil }
        return String(self[index(startIndex, offsetBy: i)])
    }
}
