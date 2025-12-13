//
//  OpenAIStreamingResponse.swift
//  AIChatBot
//
//  Created by Ahsan Murtaza on 23/09/2025.
//

import Foundation

struct OpenAIStreamingResponse: Decodable {
    let type: StreamEventType
    let response: OpenAIResponse?
    let sequenceNumber: Int?
    let outputIndex: Int?
    let item: Item?
    let part: Content?
    let itemId: String?
    let contentIndex: Int?
    let annotationIndex: Int?
    let text: String?
    let delta: String?
    let partialImageIndex: Int?
    let partialImageBase64: String?
    let annotation: TextAnnotation?
    let errorCode: String?
    let errorMessage: String?
    let errorParameter: String?
    
    enum CodingKeys: String, CodingKey {
        case type, response, item, part, text, delta, annotation
        case sequenceNumber = "sequence_number"
        case outputIndex = "output_index"
        case itemId = "item_id"
        case contentIndex = "content_index"
        case partialImageIndex = "partial_image_index"
        case partialImageBase64 = "partial_image_b64"
        case errorCode = "code"
        case errorMessage = "message"
        case errorParameter = "param"
        case annotationIndex = "annotation_index"
    }
    
    enum StreamEventType: String, Decodable {
        case responseCreated = "response.created"
        case responseInProgress = "response.in_progress"
        case responseCompleted = "response.completed"
        case responseFailed = "response.failed"
        case responseIncomplete = "response.incomplete"
        case responseOutputItemAdded = "response.output_item.added"
        case responseOutputItemDone = "response.output_item.done"
        case responseContentPartAdded = "response.content_part.added"
        case responseContentPartDone = "response.content_part.done"
        case responseOutputTextDelta = "response.output_text.delta"
        case responseOutputTextDone = "response.output_text.done"
        case responseRefusalDelta = "response.refusal.delta"
        case responseRefusalDone = "response.refusal.done"
        case responseWebSearchCallInProgress = "response.web_search_call.in_progress"
        case responseWebSearchCallSearching = "response.web_search_call.searching"
        case responseWebSearchCallCompleted = "response.web_search_call.completed"
        case responseReasoningSummaryPartAdded = "response.reasoning_summary_part.added"
        case responseReasoningSummaryPartDone = "response.reasoning_summary_part.done"
        case responseReasoningSummaryTextDelta = "response.reasoning_summary_text.delta"
        case responseReasoningSummaryTextDone = "response.reasoning_summary_text.done"
        case responseReasoningTextDelta = "response.reasoning_text.delta"
        case responseReasoningTextDone = "response.reasoning_text.done"
        case responseImageGenerationCallCompleted = "response.image_generation_call.completed"
        case responseImageGenerationCallGenerating = "response.image_generation_call.generating"
        case responseImageGenerationCallInProgress = "response.image_generation_call.in_progress"
        case responseImageGenerationCallPartialImage = "response.image_generation_call.partial_image"
        case responseOutputTextAnnotationAdded = "response.output_text.annotation.added"
        case responseQueued = "response.queued"
        case error = "error"
    }
    
    struct Item: Decodable {
        let id: String?
        let status: Status?
        let type: String?
        let role: Role?
        let content: [Content]?
        
        enum Status: String, Decodable {
            case completed, incomplete
            case inProgress = "in_progress"
        }
    }
}

struct TextAnnotation: Decodable {
    let type: String?
    let text: String?
    let start: Int?
    let end: Int?
}
