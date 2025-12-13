//
//  NSAppearance.swift
//  ChatGPTmacAR
//
//  Created by Macbook Pro on 25/05/2025.
//

import Foundation
import AppKit

extension NSAppearance {
    public var isDarkMode: Bool {
        if #available(macOS 10.14, *) {
            if self.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
}
