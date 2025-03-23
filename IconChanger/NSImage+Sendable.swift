//
//  NSImage+Sendable.swift
//  IconChanger
//
//  Created by Bengerthelorf on 3/24/25.
//

import AppKit

// 标记NSImage为符合Sendable协议
// 使用@unchecked因为我们手动确保它的安全使用
extension NSImage: @unchecked @retroactive Sendable {}
