//
//  Message.swift
//  ChatGPTmacAR
//
//  Created by Macbook Pro on 24/05/2025.
//

import Foundation

public struct Message: Codable, Sendable {
    public let role: String
    public var content: String
    public var reasoningContent: String?
    public var thinkTime: Int?
    public var annotations: [Annotation]?
    
    public init(role: String, content: String) {
        self.role = role
        self.content = content
    }
    
    func isAssistantMessage() -> Bool {
        role == Role.assistant.rawValue
    }
    
    func isImageMessage() -> Bool {
        content.hasPrefix("data:image/jpeg;base64,")
    }
}

public struct Request: Encodable {
    let model: String
    let messages: [Message]
    let temperature: Double?
    let stream: Bool
}

public struct RequestReasoning: Encodable {
    let model: String
    let input: [Message]
    let reasoning: Reasoning?
    let tools: [Tool]?
    let stream: Bool
    
    init(model: String, input: [Message], reasoning: Reasoning, stream: Bool) {
        self.model = model
        self.input = input
        self.reasoning = reasoning
        self.tools = nil
        self.stream = stream
    }
    
    init(model: String, input: [Message], reasoning: Reasoning, tools: [Tool], stream: Bool) {
        self.model = model
        self.input = input
        self.reasoning = reasoning
        self.tools = tools
        self.stream = stream
    }
}

public struct Reasoning: Encodable {
    let effort: String
    let summary: String
}

public struct Tool: Encodable {
    let type: String
}

public struct StreamCompletionResponse: Codable {
    let id: String?
    let choices: [StreamChoice]
}

public struct StreamChoice: Codable {
    let delta: Delta
}

public struct Delta: Codable {
    let content: String?
    let reasoningContent: String?
    let annotations: [Annotation]?
}

public struct Annotation: Codable, Sendable {
    let type: String
    let urlCitation: URLCitation
}

public struct URLCitation: Codable, Sendable {
    let startIndex: Int
    let endIndex: Int
    let title: String
    let url: String
}

public struct CompletionResponse: Codable {
    let id: String?
    let choices: [Choice]
}

public struct Choice: Codable {
    let message: Message
}

public struct ErrorResponse: Codable {
    let message: String
    let type: String?
    let code: Int?
}

public struct ReasoningDelta: Codable {
    let type: String
    let delta: String?
}

