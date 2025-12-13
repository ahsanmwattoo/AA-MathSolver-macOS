//
//  OpenAIError.swift
//  AIChatBot
//
//  Created by Ahsan Murtaza on 23/09/2025.
//

import Foundation

enum OpenAIError: Error {
    case invalidURL
    case invalidNetworkResponse(errorMessage: String)
    case decodingError(error: Error)
    case encodingError
    case requestBuilderError
    case invalidData
}
