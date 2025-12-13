//
//  RealMathEngine.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 08/12/2025.
//

import Foundation
import Expression

class RealMathEngine {
    
    var isDegreeMode = true
    
    func evaluate(_ input: String) -> String {
        let cleaned = preprocess(input)
        
        do {
            let expression = AnyExpression(
                cleaned,
                options: [.noOptimize],
                constants: [
                    "pi": Double.pi,
                    "e":  M_E,
                    "π":  Double.pi
                ]
            )
            
            let result: Double = try expression.evaluate()
            
            if result.truncatingRemainder(dividingBy: 1) == 0 {
                return String(Int(result))
            } else {
                return String(format: "%.10g", result)
            }
            
        } catch {
            print("Math Error: \(error)")
            return "Error".localized()
        }
    }
    
    private func preprocess(_ input: String) -> String {
        var s = input
            .replacingOccurrences(of: "×", with: "*")
            .replacingOccurrences(of: "÷", with: "/")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "π", with: "pi")
        
        // √16 → sqrt(16)
        s = s.replacingOccurrences(of: "√", with: "sqrt(")
        
        // sin45 → sin(45) — but NOT for lim(, Σ(, d/dx(, ∫(
        let safeFunctions = ["sin", "cos", "tan", "ln", "log", "exp", "sqrt", "abs"]
        for f in safeFunctions {
            let pattern = "\(f)(?=[0-9πe\\-\\+\\.])"
            if let regex = try? NSRegularExpression(pattern: pattern) {
                s = regex.stringByReplacingMatches(in: s, range: NSRange(s.startIndex..., in: s), withTemplate: "$0(")
            }
        }
        
        // Degree mode — sirf sin/cos/tan ko convert karo, baaki ko chhodo
        if isDegreeMode {
            s = convertOnlyTrigToRadians(s)
        }
        
        // Implicit multiplication
        s = addImplicitMultiplication(s)
        
        return s
    }

    // Sirf sin/cos/tan ko degree → radian, lim( ko nahi chhuna!
    private func convertOnlyTrigToRadians(_ input: String) -> String {
        var s = input
        
        let trigFuncs = ["sin", "cos", "tan"]
        for f in trigFuncs {
            let regex = try! NSRegularExpression(pattern: "\(f)(\\([^()]+\\))")
            while let match = regex.firstMatch(in: s, range: NSRange(s.startIndex..., in: s)),
                  let fullRange = Range(match.range, in: s),
                  let contentRange = Range(match.range(at: 1), in: s) {
                
                let content = String(s[contentRange])
                let newExpr = "\(f)((\(content)) * (pi/180))"
                s.replaceSubrange(fullRange, with: newExpr)
            }
        }
        
        return s
    }
    
    private func addImplicitMultiplication(_ input: String) -> String {
        var s = input
        let patterns = [
            "(\\d)([a-zA-Zπ])": "$1*$2",
            "([a-zA-Zπ])(\\d)": "$1*$2",
            "(\\))([a-zA-Zπ\\(])": "$1*$2",
            "([a-zA-Zπ])\\(": "$1*("
        ]
        for (pattern, template) in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern) {
                s = regex.stringByReplacingMatches(in: s, range: NSRange(s.startIndex..., in: s), withTemplate: template)
            }
        }
        return s
    }
    
    // MARK: - Summation Support (Σ)
    func summation(_ input: String) -> String {
        if let range = input.range(of: " to ") {
            let startStr = input[..<range.lowerBound].trimmingCharacters(in: .whitespaces)
            let endStr = input[range.upperBound...].trimmingCharacters(in: .whitespaces)
            
            guard let start = Int(startStr), let end = Int(endStr) else {
                return "Error: Invalid range".localized()
            }
            
            var sum: Double = 0
            for i in start...end {
                sum += Double(i)
            }
            return String(format: "%.10g", sum)
        }
        
        // Case 2: Σ(n=1 to 5, n²)
        let advancedPattern = try? NSRegularExpression(pattern: "([a-zA-Z])=([0-9\\-\\+\\.]+) to ([0-9\\-\\+\\.]+),(.+)")
        if let match = advancedPattern?.firstMatch(in: input, range: NSRange(input.startIndex..., in: input)),
           let varRange = Range(match.range(at: 1), in: input),
           let startRange = Range(match.range(at: 2), in: input),
           let endRange = Range(match.range(at: 3), in: input),
           let exprRange = Range(match.range(at: 4), in: input) {
            
            let variable = String(input[varRange])
            let start = Int(input[startRange]) ?? 0
            let end = Int(input[endRange]) ?? 0
            let expressionTemplate = String(input[exprRange])
            
            var total: Double = 0
            for i in start...end {
                let expr = expressionTemplate.replacingOccurrences(of: variable, with: "\(i)")
                let result = evaluate(expr)
                if result.contains("Error".localized()) { return "Error in expression".localized() }
                total += Double(result) ?? 0
            }
            
            return String(format: "%.10g", total)
        }
        
        return "Error: Invalid summation".localized()
    }
}
