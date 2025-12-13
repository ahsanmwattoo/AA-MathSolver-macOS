//
//  CoreDataStackProvider.swift
//  ChatGPTmacAR
//
//  Created by Ahsan Murtaza on 29/08/2025.
//

import Foundation

class CoreDataStackProvider {
    static let shared = CoreDataStackProvider()
    let stack: CoreDataStack
    
    private init() {
        self.stack = CoreDataStack(modelName: "HistoryCoreData", isCloudKitEnabled: false)
    }
}
