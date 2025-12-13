//
//  File.swift
//  ChatGPT-mac-AB
//
//  Created by Ahsan Murtaza on 11/12/2025.
//

import Foundation

extension Encodable {
    func toDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }
}
