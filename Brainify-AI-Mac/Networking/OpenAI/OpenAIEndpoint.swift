//
//  OpenAIEndpoint.swift
//  AIChatBot
//
//  Created by Ahsan Murtaza on 23/09/2025.
//

import Foundation

enum OpenAIEndpoint {
    case chatCompletions
    case responses
    
    var path: String {
        switch self {
        case .chatCompletions:
            return "/v1/chat/completions"
        case .responses:
            return "/v1/responses"
        }
    }
}
