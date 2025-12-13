//
//  OpenAIService.swift
//  AIChatBot
//
//  Created by Ahsan Murtaza on 23/09/2025.
//

import Foundation

final class OpenAIService: APIClient {
    
    private var incompleteBuffer = ""
    private var apiKey: String {
        AppConstants.key
    }
    var task: URLSessionTask?
    private var headers: [String: String] {
        return [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
    }
    
    func cancelAllTasks() {
        networkClient.cancelTask()
        task?.cancel()
    }
    
    func getResponse(
        model: String,
        input: [InputOutput],
        instructions: String,
        reasoning: OpenAIResponsesRequest.Reasoning? = nil,
        tools: [OpenAIResponsesRequest.Tool]? = nil
    ) async throws -> OpenAIResponse {
        let openAIRequest = OpenAIResponsesRequest(
            model: model,
            input: input,
            instructions: instructions,
            reasoning: reasoning,
            tools: tools
        )
        
        let body = try JSONEncoder().encode(
            openAIRequest
        )
        
        let request = try RequestBuilder.build(
            httpMethod: .POST,
            baseURL: baseURL,
            endpoint: .responses,
            headers: headers,
            body: body
        )
        
        let response = try await networkClient.performRequest(
            request
        )
        return try responseDecoder
            .decode(
                from: response
            )
    }
    
    func getStreamingResponse(
        model: String,
        input: [InputOutput],
        instructions: String,
        reasoning: OpenAIResponsesRequest.Reasoning? = nil,
        tools: [OpenAIResponsesRequest.Tool]? = nil
    ) throws -> AsyncThrowingStream<
        OpenAIStreamingResponse,
        Error
    > {
        let openAIRequest = OpenAIResponsesRequest(
            model: model,
            input: input,
            instructions: instructions,
            reasoning: reasoning,
            tools: tools,
            stream: true
        )
        
        let body = try JSONEncoder().encode(
            openAIRequest
        )
        
        let request = try RequestBuilder.build(
            httpMethod: .POST,
            baseURL: baseURL,
            endpoint: .responses,
            headers: headers,
            body: body
        )
        
        incompleteBuffer = ""
        let delegate = CertificatePin()
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 120
        let session = URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
        task = session.dataTask(with: request)
        task?.resume()
        
        return AsyncThrowingStream { continuation in
            delegate.onData = { [weak self] chunk in
                guard let self else { return }
                processStreamLine(chunk) { response in
                    if let response {
                        continuation.yield(response)
                    }
                }
            }
            
            delegate.onError = { error in
                continuation.finish(throwing: error)
            }
        }
    }
    
    func processStreamLine(_ string: String, completion: @escaping (OpenAIStreamingResponse?) -> Void) {
        print("Line: \(string)")
        
        incompleteBuffer += string
        let lines = incompleteBuffer.components(separatedBy: "\r\n\r\n").flatMap {
            $0.components(separatedBy: "\n\n") }
        
        for chunk in lines {
            print("Chunk: \(chunk)")
            if chunk.isEmpty { continue }
            
            if let jsonStartIndex = chunk.range(of: "data: ")?.upperBound {
                let jsonString = String(chunk[jsonStartIndex...])
                if let jsonData = jsonString.data(using: .utf8) {
                    do {
                        let decodedResponse: OpenAIStreamingResponse = try responseDecoder.decode(from: jsonData)
                        completion(decodedResponse)
                    } catch {
                        print("Decoding Error 🚫: \(error)")
                    }
                }
            }
        }
        
        incompleteBuffer = lines.last ?? ""
    }
    
    func streamCompletion(model: String,
                          input: [InputOutput],
                          instructions: String,
                          reasoning: OpenAIResponsesRequest.Reasoning? = nil,
                          tools: [OpenAIResponsesRequest.Tool]? = nil,
                          completion: @escaping (Result<OpenAIStreamingResponse, Error>) -> Void) {
        
        let openAIRequest = OpenAIResponsesRequest(
            model: model,
            input: input,
            instructions: instructions,
            reasoning: reasoning,
            tools: tools,
            stream: true
        )
        
        guard let body = try? JSONEncoder().encode(openAIRequest) else {
            completion(.failure(OpenAIError.encodingError))
            return
        }
        
        guard let request = try? RequestBuilder.build(
            httpMethod: .POST,
            baseURL: baseURL,
            endpoint: .responses,
            headers: headers,
            body: body
        ) else {
            completion(.failure(OpenAIError.requestBuilderError))
            return
        }
        
        let delegate = CertificatePin()
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 120
        let session = URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
        task = session.dataTask(with: request)
        task?.resume()
        
        delegate.onData = { [weak self] line in
            print("Line: \(line)")
            guard let self else { return }
            do {
                var newLine = line
                if newLine.hasPrefix("data: ") {
                    let truncated = newLine.dropFirst(6)
                    newLine = String(truncated)
                    
                    guard let responseData = newLine.data(using: .utf8) else {
                        completion(.failure(OpenAIError.invalidData))
                        return
                    }
                    let decodedResponse: OpenAIStreamingResponse = try responseDecoder.decode(from: responseData)
                    
                    completion(.success(decodedResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        delegate.onError = { error in
            completion(.failure(error))
        }
    }
}
