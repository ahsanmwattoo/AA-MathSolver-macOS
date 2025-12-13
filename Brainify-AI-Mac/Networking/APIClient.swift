//
//  APIClient.swift
//  AIChatBot
//
//  Created by Ahsan Murtaza on 23/09/2025.
//

import Foundation

protocol APIClientProtocol {
    var baseURL: String { get set }
    var networkClient: NetworkClient { get }
    var responseDecoder: ResponseDecoder { get }
}

class APIClient: APIClientProtocol {
    var baseURL: String
    internal let networkClient: NetworkClient
    internal let responseDecoder: ResponseDecoder
    
    init(
        baseURL: String,
        networkClient: NetworkClient = DefaultNetworkClient(),
        responseDecoder: ResponseDecoder = DefaultResponseDecoder()
    ) {
        self.baseURL = baseURL
        self.networkClient = networkClient
        self.responseDecoder = responseDecoder
    }
}
