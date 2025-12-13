//
//  OpenAIResponsesRequest.swift
//  AIChatBot
//
//  Created by Ahsan Murtaza on 23/09/2025.
//

import Foundation

struct OpenAIResponsesRequest: Encodable {
    let model: String
    let input: [InputOutput]
    var instructions: String?
    var maxOutputTokens: Int?
    var maxToolCalls: Int?
    var parallelToolCalls: Bool?
    var previousResponseID: String?
    var temperature: Double?
    var reasoning: Reasoning?
    var tools: [Tool]?
    var stream: Bool?
    
    enum CodingKeys: String, CodingKey {
        case model, input, instructions, reasoning, tools, stream
        case maxOutputTokens = "max_output_tokens"
        case maxToolCalls = "max_tool_calls"
        case previousResponseID = "previous_response_id"
        case parallelToolCalls = "parallel_tool_calls"
    }
    
    struct Reasoning: Encodable {
        enum ReasoningEffort: String, Encodable {
            case low, medium, high
        }
        
        enum Summary: String, Encodable {
            case auto, concise, detailed
        }
        
        let effort: ReasoningEffort?
        let summary: Summary?
    }
    
    struct Tool: Encodable {
        enum ToolType: String, Encodable {
            case webSearch = "web_search_preview"
            case imageGeneration = "image_generation"
        }
        
        let type: ToolType
    }
}
