//
//  GrokAIAPI.swift
//  AIChatbot
//
//  Created by Aiman Batool on 28/01/2025.
//

import Foundation
import FirebaseFunctions

class GPTService: @unchecked Sendable {
    
    enum Constants {
        static let defaultModel = "gpt-3.5-turbo"
        static let GPT5reasoning = "gpt-5"
        static let GPT5mini = "gpt-5-mini"
        static let GPT5nano = "gpt-5-nano"
        static let GPT5 = "gpt-5-chat-latest"
        
        static let GPT3_5 = "gpt-3.5-turbo"
        static let GPT4Turbo = "gpt-4-turbo"
        static let GPT4 = "gpt-4"
        static let GPT4_1 = "gpt-4.1"
        static let GPT4_1nano = "gpt-4.1-nano"
        static let GPT4_1mini = "gpt-4.1-mini"
        static let GPT4o = "gpt-4o"
        static let GPT4o_mini = "gpt-4o-mini"
        static let o1 = "o1"
        static let o1Pro = "o1-pro"
        static let o1Mini = "o1-mini"
        static let o3Mini = "o3-mini"
        static let o3 = "o3"
        static let o3Pro = "o3-pro"
        static let o4Mini = "o4-mini"
        static let search4o = "gpt-4o-search-preview"
        static let search4oMini = "gpt-4o-mini-search-preview"
        static let image1 = "gpt-image-1"
        static let dalle3 = "dall-e-3"
        static let dalle2 = "dall-e-2"
        
        static let defaultSystemText = "You're a helpful assistant"
        static let defaultTemperature = 1.0
    }
    
    private let urlString = "https://api.openai.com/v1/chat/completions"
    private let urlStringResponse = "https://api.openai.com/v1/responses"
    private let urlStringImage = "https://api.openai.com/v1/images/generations"
    
    public private(set) var historyList = [Message]()
    private var historyLimit: Int = 12;
    var incompleteBuffer = ""
    var task: URLSessionTask?
    private let functions = Functions.functions()
    
    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }()
    
    func funcionsCall(text: String, model: String = GPTService.Constants.defaultModel, systemText: String = GPTService.Constants.defaultSystemText, temperature: Double = GPTService.Constants.defaultTemperature) async throws -> String {
        
        let messages = composeMessages(text: text, systemText: systemText)
        let requestBody = Request(
            model: model,
            messages: messages,
            temperature: temperature,
            stream: false
        )
        
        guard let payload = requestBody.toDictionary() else {
            throw NSError(domain: "Invalid Payload", code: 0, userInfo: nil)
        }
        
        let result = try await functions.httpsCallable("completion").call(payload)
        
        guard let dictionary = result.data as? [String: Any] else {
            throw NSError(domain: "Invalid response format", code: 0, userInfo: nil)
        }
        
        let data = try JSONSerialization.data(withJSONObject: dictionary)
        
        let completionResponse = try jsonDecoder.decode(CompletionResponse.self, from: data)
        let responseText = completionResponse.choices.first?.message.content ?? ""
        updateHistory(userText: text, responseText: responseText)
        return responseText
    }
    
    func getResponse(
        model: String,
        input: [InputOutput],
        instructions: String,
        reasoning: OpenAIResponsesRequest.Reasoning? = nil,
        tools: [OpenAIResponsesRequest.Tool]? = nil
    ) async throws -> String {
        let openAIRequest = OpenAIResponsesRequest(
            model: model,
            input: input,
            instructions: instructions,
            reasoning: reasoning,
            tools: tools
        )
        
        guard let payload = openAIRequest.toDictionary() else {
            throw NSError(domain: "Invalid Payload", code: 0, userInfo: nil)
        }
        
        let result = try await functions.httpsCallable("responses").call(payload)
        
        guard let dictionary = result.data as? [String: Any] else {
            throw NSError(domain: "Invalid response format", code: 0, userInfo: nil)
        }
        
        let data = try JSONSerialization.data(withJSONObject: dictionary)
        
        print("String: \(String(data: data, encoding: .utf8))")
        
        let response = try jsonDecoder.decode(OpenAIResponse.self, from: data)
        return response.output?.first?.content?.first(where: { $0.type == .outputText })?.text ?? "Empty String"
    }
    
    func updateHistory(userText: String, responseText: String) {
        historyList.append(Message(role: "user", content: userText))
        historyList.append(Message(role: "assistant", content: responseText))
    }
    
    //        let session = URLSession.shared
    //
    //        if isImageGeneration {
    //            let (data, response) = try await session.data(for: request)
    //            try validate(response: response)
    //            return AsyncThrowingStream<(reasoning: String?, content: String, annotaions: [Annotation]), Error> { continuation in
    //
    //                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
    //                   let dataArray = json["data"] as? [[String: Any]],
    //                   let firstItem = dataArray.first
    //                   {
    //                    if let b64String = firstItem["b64_json"] as? String {
    //                        continuation.yield((nil, b64String, []))
    //                        continuation.finish()
    //                    }else if let urlString = firstItem["url"] as? String{
    //                        continuation.yield((nil, urlString, []))
    //                        continuation.finish()
    //                    }else{
    //                        continuation.finish(throwing: NSError(domain: "Image generaion fail", code: 9999))
    //                    }
    //
    //                } else {
    //                    let error = NSError(domain: "Failed to generate image from base64", code: 0)
    //                    continuation.finish(throwing: error)
    //                }
    //            }
    //        } else {
    //            let (result, response) = try await URLSession.shared.bytes(for: request)
    //            try validate(response: response)
    //
    //            return AsyncThrowingStream<(reasoning: String?, content: String, annotaions: [Annotation]), Error> { continuation in
    //                Task(priority: .userInitiated) { [weak self] in
    //                    do {
    //                        for try await line in result.lines {
    //                            if let text = try self?.processStreamLine(
    //                                line,
    //                                isReasoning: isReasoning || isDeepResearch
    //                            ) {
    //                                continuation.yield(text)
    //                            }
    //                        }
    //                        continuation.finish()
    //                    } catch {
    //                        print("Erorr: \(error)")
    //                        print("Localized description: \(error.localizedDescription)")
    //                        continuation.finish(throwing: error)
    //                    }
    //                }
    //            }
    //        }
    
    // MARK: - History Management
    
    public func clearHistory() {
        historyList.removeAll()
    }
    
    public func replaceHistory(with messages: [Message]) {
        let newMessages: [Message] = messages.compactMap { message in
            let content = message.content.isBase64Image ? "" : message.content
            return Message.init(role: message.role, content: content)
        }
        historyList = newMessages
    }
    
    // MARK: - Private Helpers
    
    private func createRequest(token: String,
                               text: String,
                               model: String,
                               systemText: String,
                               temperature: Double,
                               stream: Bool,
                               isWebSearch: Bool,
                               isReasoning: Bool,
                               isDeepResearch: Bool,
                               isImageGeneration: Bool) throws -> URLRequest {
        var urlRequest = URLRequest(url: URL(string: isReasoning || isDeepResearch ? urlStringResponse : (isImageGeneration ? urlStringImage : urlString))!)
        urlRequest.httpMethod = "POST"
        headers(token: token).forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        let messages = composeMessages(text: text, systemText: systemText)
        
        if isImageGeneration {
            let requestBody: [String: Any] = ["model": model, "prompt" : text, "n": 1, "size": "1024x1024"]
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } else if isReasoning {
            let requestBody = RequestReasoning(
                model: model,
                input: messages,
                reasoning: Reasoning(effort: "medium", summary: "detailed"),
                stream: stream
            )
            urlRequest.httpBody = try JSONEncoder().encode(requestBody)
        } else if isDeepResearch {
            let requestBody = RequestReasoning(
                model: model,
                input: messages,
                reasoning: Reasoning(effort: "medium", summary: "detailed"),
                tools: [Tool(type: "web_search_preview")],
                stream: stream
            )
            urlRequest.httpBody = try JSONEncoder().encode(requestBody)
        } else {
            let requestBody = Request(
                model: model,
                messages: messages,
                temperature: isWebSearch ? nil : (model == Constants.o3 || model == Constants.o4Mini) ? 1 : ((model == Constants.o3Mini || model == Constants.o1) ? nil : 0.7),
                stream: stream
            )
            urlRequest.httpBody = try JSONEncoder().encode(requestBody)
        }
        
        return urlRequest
    }
    
    func headers(token: String) -> [String: String] {
        return [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(AppConstants.key)"
            //            "x-firebase-appcheck": token
        ]
    }
    
    private func composeMessages(text: String, systemText: String) -> [Message] {
        let systemMessage = Message(role: "system", content: systemText)
        return [systemMessage] + historyList + [Message(role: "user", content: text)]
    }
    
    private func processStreamLine(_ line: String, isReasoning: Bool) throws -> (String?, String, [Annotation]) {
        print("Line: \(line)")
        incompleteBuffer += line
        let lines = isReasoning ? incompleteBuffer.components(separatedBy: "\r\n\r\n").flatMap {
            $0.components(separatedBy: "\n\n") } : incompleteBuffer.components(separatedBy: .newlines)
        
        var reasoning: String = ""
        var content: String = ""
        var returnableAnnotations: [Annotation] = []
        for chunk in lines {
            if isReasoning {
                if chunk.isEmpty { continue }
                
                if chunk.hasPrefix("event: response.output_text.done") {
                    break
                }
                
                if chunk.hasPrefix("event: response.reasoning_summary_text.delta") {
                    if let jsonStartIndex = chunk.range(of: "data: ")?.upperBound {
                        let jsonString = String(chunk[jsonStartIndex...])
                        if let jsonData = jsonString.data(using: .utf8) {
                            do {
                                let result = try JSONDecoder().decode(ReasoningDelta.self, from: jsonData)
                                reasoning += result.delta ?? ""
                            } catch {
                                print("Decoding error:")
                            }
                        }
                    }
                }  else if chunk.hasPrefix("event: response.output_text.delta") {
                    if let jsonStartIndex = chunk.range(of: "data: ")?.upperBound {
                        let jsonString = String(chunk[jsonStartIndex...])
                        if let jsonData = jsonString.data(using: .utf8) {
                            do {
                                let result = try JSONDecoder().decode(ReasoningDelta.self, from: jsonData)
                                content += result.delta ?? ""
                            } catch {
                                print("Decoding error content:")
                            }
                        }
                    }
                }
            } else {
                if chunk.isEmpty { continue }
                
                if chunk == "data: [DONE]" {
                    break
                }
                
                if chunk.hasPrefix("data: "),
                   let data = chunk.dropFirst(6).data(using: .utf8),
                   let response = try? jsonDecoder.decode(StreamCompletionResponse.self, from: data) {
                    content += response.choices.first?.delta.content ?? ""
                    if let annotations = response.choices.first?.delta.annotations, returnableAnnotations.isEmpty {
                        returnableAnnotations = annotations
                    }
                }
            }
        }
        incompleteBuffer = lines.last ?? ""
        return (reasoning.isEmpty ? nil : reasoning, content, returnableAnnotations)
    }
    
    //    private func processStreamLine(_ line: String, isReasoning: Bool) throws -> (String?, String, [Annotation]) {
    //        incompleteBuffer += line
    //
    //        let lines = isReasoning ? incompleteBuffer.components(separatedBy: "\r\n\r\n").flatMap {
    //            $0.components(separatedBy: "\n\n") } : incompleteBuffer.components(separatedBy: .newlines)
    //
    ////        let lines = isReasoning ? [line] : line.components(separatedBy: .newlines)
    //
    //        var reasoning: String = ""
    //        var content: String = ""
    //        var returnableAnnotations: [Annotation] = []
    //        for chunk in lines {
    //            if isReasoning {
    //                if chunk.isEmpty { continue }
    //
    //                if chunk.hasPrefix("data:") {
    //                    let chunk = chunk.dropFirst(5).trimmingCharacters(in: .whitespacesAndNewlines)
    //                    if chunk.hasPrefix("{type: response.output_text.done") {
    //                        break
    //                    }
    //
    //                    if chunk.hasPrefix("{\"type\":\"response.reasoning_summary_text.delta") {
    //                        if let jsonData = chunk.data(using: .utf8) {
    //                            do {
    //                                let result = try JSONDecoder().decode(ReasoningDelta.self, from: jsonData)
    //                                reasoning += result.delta ?? ""
    //                            } catch {
    //                                print("Decoding error: \(error)")
    //                            }
    //                        }
    //                    } else if chunk.hasPrefix("{\"type\":\"response.output_text.delta") {
    //                        if let jsonData = chunk.data(using: .utf8) {
    //                            do {
    //                                let result = try JSONDecoder().decode(ReasoningDelta.self, from: jsonData)
    //                                content += result.delta ?? ""
    //                            } catch {
    //                                print("Decoding error content: \(error)")
    //                            }
    //                        }
    //                    }
    //                }
    //            } else {
    //                if chunk.isEmpty { continue }
    //
    //                if chunk == "data: [DONE]" {
    //                    break
    //                }
    //
    //                if chunk.hasPrefix("data: "),
    //                   let data = chunk.dropFirst(6).data(using: .utf8) {
    //                    let response = try jsonDecoder.decode(StreamCompletionResponse.self, from: data)
    //                    content += response.choices.first?.delta.content ?? ""
    //                    if let annotations = response.choices.first?.delta.annotations, returnableAnnotations.isEmpty {
    //                        returnableAnnotations = annotations
    //                    }
    //                }
    //            }
    //        }
    //        incompleteBuffer = lines.last ?? ""
    //        return (reasoning.isEmpty ? nil : reasoning, content, returnableAnnotations)
    //    }
    
    private func validate(response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "ChatGPT", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response type"])
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw NSError(domain: "ChatGPT", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error: \(httpResponse.statusCode)"])
        }
    }
}
