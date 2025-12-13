//
//  ResponseDecoder.swift
//  AIChatBot
//
//  Created by Ahsan Murtaza on 23/09/2025.
//

import Foundation

protocol ResponseDecoder {
    func decode<T: Decodable>(from data: Data) throws -> T
}

final class DefaultResponseDecoder: ResponseDecoder {
    func decode<T>(from data: Data) throws -> T where T : Decodable {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw OpenAIError.decodingError(error: error)
        }
    }
}
