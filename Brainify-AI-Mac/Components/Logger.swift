//
//  Logger.swift
//  ChatGPTmacAR
//
//  Created by Macbook Pro on 19/06/2025.
//

import OSLog

class CZLogger {
    private static let errorLogger: Logger = .init(subsystem: Bundle.main.bundleIdentifier ?? "ChatGPT - macOS", category: "Error")
    
    static func logError(error: String) {
        errorLogger.log("Error: \(error)")
    }
}
