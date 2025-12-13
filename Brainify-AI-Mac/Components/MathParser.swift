//
//  MathParser.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 08/12/2025.
//


import Foundation

final class MathParser {
    
    func evaluate(_ expression: String) -> Double? {
        guard !expression.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        
        let processed = preprocess(expression)
        return evaluateNSExpression(processed)
    }
    
    private func preprocess(_ input: String) -> String {
        var s = input
            .replacingOccurrences(of: "×", with: "*")
            .replacingOccurrences(of: "÷", with: "/")
            .replacingOccurrences(of: "π", with: "pi")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "ln(", with: "log(")
            .replacingOccurrences(of: "|", with: "")
        s = s.replacingOccurrences(of: "e^(", with: "pow(e,")
        s = s.replacingOccurrences(of: "e^", with: "pow(e,")
        
        s = replacePowerOperator(s)
        
        return s
    }
    
    private func replacePowerOperator(_ input: String) -> String {
        var s = input
        let pattern = "([0-9a-zA-Zπ.()]+)\\^([0-9a-zA-Zπ.()+-]+)"
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return s
        }
        
        while let match = regex.firstMatch(in: s, range: NSRange(s.startIndex..., in: s)) {
            guard
                let fullSwiftRange = Range(match.range, in: s),
                let baseRange = Range(match.range(at: 1), in: s),
                let expRange = Range(match.range(at: 2), in: s)
            else { break }
            
            let base = String(s[baseRange])
            let exp = String(s[expRange])
            let replacement = "pow(\(base),\(exp))"
            
            s.replaceSubrange(fullSwiftRange, with: replacement)
        }
        
        return s
    }
    
    private func evaluateNSExpression(_ expression: String) -> Double? {
        do {
            let exp = NSExpression(format: expression)
            if let result = exp.expressionValue(with: nil, context: nil) as? NSNumber {
                return result.doubleValue.isFinite ? result.doubleValue : nil
            }
        } catch {
            print("MathParser Error: \(error.localizedDescription)")
            print("Expression was: \(expression)")
        }
        return nil
    }
}
