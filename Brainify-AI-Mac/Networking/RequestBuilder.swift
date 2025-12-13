//
//  RequestBuilder.swift
//  AIChatBot
//
//  Created by Ahsan Murtaza on 23/09/2025.
//

import Foundation

class RequestBuilder {
    enum HTTPMethod: String {
        case GET
        case POST
        case PUT
        case PATCH
        case DELETE
    }
    
    static func build(
        httpMethod: HTTPMethod,
        baseURL: String,
        endpoint: OpenAIEndpoint,
        headers: [String: String]? = nil,
        body: Data? = nil
    ) throws -> URLRequest {
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw OpenAIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        return request
    }
}
