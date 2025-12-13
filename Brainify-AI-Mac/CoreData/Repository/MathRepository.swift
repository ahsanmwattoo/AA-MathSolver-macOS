//
//  MathRepository.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 12/12/2025.
//

import Foundation

class MathRepository {
    static let shared = MathRepository()
    private let service: CoreDataService
    init() {
        let stack = CoreDataStackProvider.shared.stack
        service = .init(coreDataStack: stack)
    }

    func fetchAllChats() throws -> [CDMath] {
        try service.fetchAll(CDMath.self).reversed()
    }

    func createNewChat(
        id: String,
        problemText: String,
        problemImage: Data,
        solution: String,
        date: Date
    ) throws -> CDMath {
        let math = service.create(CDMath.self)
        math.id = id
        math.problemText = problemText
        math.problemImage = problemImage
        math.solution = solution
        math.date = date

        do {
            try service.saveContext()
            return math
        } catch {
            throw error
        }
    }
    
    func createTemporaryChat(
        id: String,
        problemText: String,
        problemImage: Data,
        solution: String,
        date: Date
    ) throws -> CDMath {
        let math = service.createTemporary(CDMath.self)
        math.id = id
        math.problemText = problemText
        math.problemImage = problemImage
        math.solution = solution
        math.date = date
        return math
    }
    
    func saveTemporaryChat(_ math: CDMath) throws {
        try service.commitTemporary(math)
    }

    func deleteChat(_ math: CDMath) throws {
        try service.delete(math)
    }
    
    func deleteAllChats() throws {
        try service.deleteAllObjects(of: CDMath.self)
    }

    func updateChat() throws {
        try service.saveContext()
    }
    
    func isTemporary(_ math: CDMath) -> Bool {
        return service.isTemporary(math)
    }
}
