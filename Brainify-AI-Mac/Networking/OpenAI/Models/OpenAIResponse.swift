//
//  OpenAIResponse.swift
//  AIChatBot
//
//  Created by Ahsan Murtaza on 23/09/2025.
//

import Foundation

struct OpenAIResponse: Decodable {
    let id: String?
    let status: Status?
    let error: ResponsesError?
    let incompleteDetails: String?
    let instructions: String?
    let maxOutputTokens: Int?
    let model: String?
    let output: [InputOutput]?
    
    enum CodingKeys: String, CodingKey {
        case id, status, error, instructions, model, output
        case incompleteDetails = "incomplete_details"
        case maxOutputTokens = "max_output_tokens"
    }
    
    enum Status: String, Decodable {
        case completed, failed, cancelled, queued, incomplete
        case inProgress = "in_progress"
    }
    
    struct ResponsesError: Decodable {
        let code: String
        let message: String
    }
}

struct Annotations: Codable {
    let type: String
    let startIndex: Int
    let endIndex: Int
    let url: String
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case type, url, title
        case startIndex = "start_index"
        case endIndex = "end_index"
    }
}

enum Role: String, Codable {
    case developer, system, assistant, user
}

struct InputOutput: Codable {
    let type: OutputType?
    let id: String?
    let role: Role?
    var content: [Content]?
    let result: String?
    
    init(
        role: Role,
        content: [Content],
        id: String? = nil,
        result: String? = nil,
        type: OutputType? = nil
    ) {
        self.role = role
        self.content = content
        self.type = nil
        self.result = nil
        self.id = nil
    }
    
    enum OutputType: String, Codable {
        case message
        case reasoning
        case webSearch = "web_search_call"
        case imageGeneration = "image_generation_call"
    }
}

struct Content: Codable {
    let type: ContentType
    var text: String?
    var fileURL: String?
    var imageURL: String?
    let annotations: [Annotations]?
    
    init(type: ContentType, text: String? = nil, annottions: [Annotations]? = nil) {
        self.type = type
        self.text = text
        self.annotations = annottions
    }
    
    init(text: String) {
        self.type = .inputText
        self.text = text
        self.fileURL = nil
        self.imageURL = nil
        self.annotations = nil
    }
    
    init(fileURL: String) {
        self.type = .inputFile
        self.text = nil
        self.fileURL = fileURL
        self.imageURL = nil
        self.annotations = nil
    }
    
    init(imageURL: String) {
        self.type = .inputImage
        self.text = nil
        self.fileURL = nil
        self.imageURL = imageURL
        self.annotations = nil
    }
    
    enum ContentType: String, Codable {
        case outputText = "output_text"
        case reasoningText = "reasoning_text"
        case inputText = "input_text"
        case inputImage = "input_image"
        case inputFile = "input_file"
    }
    
    enum CodingKeys: String, CodingKey {
        case type, text, annotations
        case fileURL = "file_url"
        case imageURL = "image_url"
    }
    
    mutating func setText(_ text: String) {
        self.text = text
    }
    
    mutating func appendText(_ text: String) {
        if var currentText = self.text {
            self.text = currentText + text
        } else {
            self.text = text
        }
    }
}
