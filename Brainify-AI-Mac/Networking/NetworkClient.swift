//
//  NetworkClient.swift
//  AIChatBot
//
//  Created by Ahsan Murtaza on 23/09/2025.
//

import Foundation

protocol NetworkClient {
    func performRequest(_ request: URLRequest) async throws -> Data
    func streamRequest(_ request: URLRequest) -> AsyncThrowingStream<String, Error>
    func cancelTask()
}

final class DefaultNetworkClient: NetworkClient {
    private var session: URLSession
    var task: Task<(), Never>?
    
    init(configuration: URLSessionConfiguration = .default, delegate: (any URLSessionDelegate)? = nil, delegateQueue: OperationQueue? = nil) {
        self.session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: delegateQueue)
    }
    
    func performRequest(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print(errorMessage)
            throw OpenAIError.invalidNetworkResponse(errorMessage: errorMessage)
        }
        return data
    }
    
    func streamRequest(_ request: URLRequest) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let t = Task {
                do {
                    let (bytes, response) = try await session.bytes(for: request)
                    guard let httpResponse = response as? HTTPURLResponse,
                          (200..<300).contains(httpResponse.statusCode) else {
                        for try await line in bytes.lines {
                            print("Line: \(line)")
                        }
                        continuation.finish(throwing: OpenAIError.invalidNetworkResponse(errorMessage: ""))
                        return
                    }
                    
                    for try await line in bytes.lines {
                        var newLine = line
                        if newLine.hasPrefix("data: ") {
                            let truncated = newLine.dropFirst(6)
                            newLine = String(truncated)
                            continuation.yield(newLine)
                        }
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            
            self.task = t
            continuation.onTermination = { @Sendable _ in
                t.cancel()
            }
        }
    }
    
    func cancelTask() {
        task?.cancel()
    }
}
