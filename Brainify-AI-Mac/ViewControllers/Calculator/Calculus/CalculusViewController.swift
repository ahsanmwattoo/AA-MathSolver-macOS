//
//  CalculusViewController.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 01/12/2025.
//

import Cocoa

class CalculusViewController: BaseViewController {
    
    static var identifier = "CalculusViewController"
    @IBOutlet weak var hideAbleStack: NSStackView!
    @IBOutlet weak var displayLabel: PlaceHolderTextView!
    @IBOutlet weak var clearButton: NSButton!
    @IBOutlet weak var solveLabel: NSTextField!
    
    private var currentExpression: String = "" {
        didSet {
            updateDisplay()
            updateClearButtonTitle()
        }
    }
    
    private var errorTimer: Timer? = nil
    private let mathEngine = RealMathEngine()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func didChangeLanguage() {
        DispatchQueue.main.async {
            [weak self] in
            guard let self else { return }
            displayLabel.placeholderString = "Type Your Equation Here...".localized()
            solveLabel.stringValue = "Solve".localized()
        }
    }
    
    func setupUI() {
        displayLabel.backgroundColor = .clear
        displayLabel.isEditable = true
        displayLabel.isSelectable = true
        displayLabel.font = NSFont.systemFont(ofSize: 22, weight: .bold)
        displayLabel.placeholderString = "Type Your Equation Here...".localized()
        displayLabel.placeholderTextColor = .secondaryText
        updateClearButtonTitle()
    }
    
    func hideAbleStackView() {
        hideAbleStack.isHidden = true
    }
    
    @IBAction func didPressSolve(_ sender: Any) {
        let result = solveCalculus(currentExpression)
        displayLabel.string = result
        currentExpression = result
        clearButton.title = "AC"
    }
    
    @IBAction func didPressNumber(_ sender: NSButton) {
        let digit = sender.title
        appendToExpression(digit)
    }
    
    @IBAction func didPressOperators(_ sender: NSButton) {
        let op = sender.title
        if currentExpression.isEmpty && (op == "-" || op == "(") {
            appendToExpression(op)
            return
        }
        if let last = currentExpression.last, "+-×÷".contains(last), "+-×÷".contains(op) {
            currentExpression.removeLast()
        }
        appendToExpression(op)
    }
    
    @IBAction func didTapDecimal(_ sender: NSButton) {
        let parts = currentExpression.components(separatedBy: CharacterSet(charactersIn: "+-×÷("))
        if let last = parts.last, !last.contains(".") {
            appendToExpression(".")
        }
    }
    
    @IBAction func didTapClear(_ sender: Any) {
        guard !currentExpression.isEmpty else { return }
        if clearButton.title == "AC" {
            currentExpression = ""
            displayLabel.string = "0"
            return
        }
        let multiCharTokens = [
            "sin", "cos", "tan", "ln", "log", "sqrt", "abs",
            "e^", "d/dx(", "∫", "π", "∑", "Error:"
        ]
        for token in multiCharTokens {
            if currentExpression.hasSuffix(token) {
                currentExpression.removeLast(token.count)
                updateDisplay()
                return
            }
        }
        currentExpression.removeLast()
        updateDisplay()
    }
    
    @IBAction func derivativePressed(_ sender: NSButton) {
        appendToExpression("d/dx(")
    }
    
    @IBAction func integralPressed(_ sender: NSButton) {
        appendToExpression("∫(")
    }
    
    @IBAction func limitPressed(_ sender: NSButton) {
        let text = "lim(x→"
        currentExpression += text
        updateDisplay()
        let cursorPos = currentExpression.count
        displayLabel.setSelectedRange(NSRange(location: cursorPos, length: 0))
    }
    
    @IBAction func piPressed(_ sender: NSButton) {
        appendToExpression("π")
    }
    
    @IBAction func summationPressed(_ sender: NSButton) {
        appendToExpression("∑(")
    }
    
    private func updateClearButtonTitle() {
        guard !hideAbleStack.isHidden else {
            clearButton.title = "C"
            return
        }
        if currentExpression.isEmpty {
            clearButton.title = "AC"
        } else {
            clearButton.title = "C"
        }
    }
    
    @IBAction func didPressEqual(_ sender: NSButton) {
        errorTimer?.invalidate()
        errorTimer = nil
                
        let result = solveCalculus(currentExpression)
            
        displayLabel.string = result
        displayLabel.textColor = result.contains("Error".localized()) ? .systemRed : .labelColor
        
        if result.contains("Error".localized()) {
            errorTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
                self.displayLabel.string = self.currentExpression.isEmpty ? "0" : self.currentExpression
                self.displayLabel.textColor = .labelColor
            }
            RunLoop.main.add(self.errorTimer!, forMode: .common)
        } else {
            currentExpression = result
        }
        clearButton.title = "AC"
    }
    
    @IBAction func inputButtonTapped(_ sender: NSButton) {
        let value = sender.title
        
        switch value {
        case "sin", "cos", "tan", "ln", "log", "sqrt":
            insertFunction(value)
        case "e^x":
            insertFunction("e^")
        case "e":
            appendToExpression("e")
        case "^2":
            appendToExpression("^2")
        case "^":
            appendToExpression("^")
        case "abs":
            appendToExpression("abs")
        case "(":
            appendToExpression("(")
        case ")":
            appendToExpression(")")
        case "=":
            didPressEqual(sender)
            return
        default:
            appendToExpression(value)
        }
    }
    
    private func insertFunction(_ funcText: String) {
        currentExpression += funcText
        updateDisplay()
        let cursorPos = currentExpression.count - 1
        displayLabel.setSelectedRange(NSRange(location: cursorPos, length: 0))
    }

    private func appendToExpression(_ text: String) {
        currentExpression += text
        updateDisplay()
    }
    
    private func updateDisplay() {
        displayLabel.string = currentExpression.isEmpty ? "0" : currentExpression
    }
    
    private func clearAll() {
        currentExpression = ""
        updateDisplay()
        updateClearButtonTitle()
    }
    
    private func solveCalculus(_ input: String) -> String {
        var expr = input.replacingOccurrences(of: " ", with: "")
        guard !expr.isEmpty else { return "0" }
        
        // Bracket check
        let open = expr.filter { $0 == "(" }.count
        let close = expr.filter { $0 == ")" }.count
        if open != close { return "Error: unmatched brackets".localized() }
        
        // LIMIT: lim(x→0)sin(x)/x  ya  lim(x→0, sin(x)/x)
        if expr.hasPrefix("lim(x→") {
            let startIndex = expr.index(expr.startIndex, offsetBy: 6) // after "lim(x→"
            var content = ""
            
            if expr.hasSuffix(")") {
                content = String(expr[startIndex..<expr.index(expr.endIndex, offsetBy: -1)])
            } else {
                content = String(expr[startIndex...])
            }
            
            // Split by comma OR by ) — dono support
            let parts = content.split(separator: ",", maxSplits: 1)
            let pointAndFunc = parts.count == 2 ? parts : content.split(separator: ")", maxSplits: 1)
            
            let point = pointAndFunc[0].trimmingCharacters(in: .whitespaces)
            let function = pointAndFunc.count > 1 ? pointAndFunc[1].trimmingCharacters(in: .whitespaces) : ""
            
            return evaluateLimit(point: point, function: function)
        }
        
        // Baaki sab same
        if expr.hasPrefix("d/dx(") && expr.hasSuffix(")") {
            let inside = String(expr.dropFirst(5).dropLast())
            return derivative(of: inside)
        }
        if expr.hasPrefix("∫(") && expr.hasSuffix(")") {
            let inside = String(expr.dropFirst(2).dropLast())
            return integral(of: inside) + " + C"
        }
        if expr.hasPrefix("Σ(") && expr.hasSuffix(")") {
            let inside = String(expr.dropFirst(2).dropLast())
            return mathEngine.summation(inside)
        }
        
        return evaluateNumeric(expr)
    }
    
    private func evaluateLimit(point: String, function: String) -> String {
        let f = function.lowercased()
        
        if point == "0" {
            if f.contains("sin(x)/x") || f.contains("x/x") { return "1" }
            if f.contains("(1-cos(x))/x^2") { return "0.5" }
            if f.contains("(e^x-1)/x") { return "1" }
            if f.contains("tan(x)/x") { return "1" }
        }
        
        if point.contains("∞") || point.contains("infinity") {
            if f.contains("1/x") { return "0" }
            if f.contains("e^-x") { return "0" }
        }
        
        return "Undefined".localized()
    }
    
    private func evaluateNumeric(_ expr: String) -> String {
        if expr.contains("x") { return "Error: x not allowed".localized() }
        return mathEngine.evaluate(expr)
    }
    
    private func derivative(of f: String) -> String {
        let terms = splitTerms(f)
        let results = terms.compactMap { diff($0) }.filter { $0 != "0" }
        return results.isEmpty ? "0" : results.joined(separator: " + ").replacingOccurrences(of: "+ -", with: "- ")
    }
        
    private func integral(of f: String) -> String {
        let terms = splitTerms(f)
        let results = terms.compactMap { integ($0) }
        return results.isEmpty ? "0" : results.joined(separator: " + ").replacingOccurrences(of: "+ -", with: "- ")
    }
        
    private func splitTerms(_ s: String) -> [String] {
        var terms: [String] = []
        var current = ""
        var depth = 0
            
        for char in s {
            if char == "(" { depth += 1 }
            if char == ")" { depth -= 1 }
            if (char == "+" || char == "-") && depth == 0 && !current.isEmpty {
                terms.append(current)
                current = char == "-" ? "-" : ""
            } else {
                current += String(char)
            }
        }
        if !current.isEmpty { terms.append(current) }
        return terms
    }
        
    private func diff(_ term: String) -> String? {
        let t = term.trimmingCharacters(in: .whitespaces)
        if let num = Double(t) { return "0" }
        if t == "x" { return "1" }
        if t == "-x" { return "-1" }
        
        let map: [String: String] = [
            "sin(x)": "cos(x)", "cos(x)": "-sin(x)", "tan(x)": "sec^2(x)",
            "e^x": "e^x", "ln(x)": "1/x", "log(x)": "1/(x*ln(10))",
            "sqrt(x)": "1/(2*sqrt(x))"
        ]
        if let r = map[t] { return r }
        let regex = try? NSRegularExpression(pattern: "^([+-]?)(\\d*\\.?\\d*)\\*?x\\^?(\\d*)$")
        if let match = regex?.firstMatch(in: t, range: NSRange(t.startIndex..., in: t)),
           let coeffRange = Range(match.range(at: 2), in: t),
           let powRange = Range(match.range(at: 3), in: t) {
            let cStr = String(t[coeffRange])
            let c = cStr.isEmpty ? 1.0 : (cStr == "-" ? -1.0 : Double(cStr) ?? 1.0)
            let p = Int(String(t[powRange])) ?? 1
            if p == 0 { return "0" }
            let newC = c * Double(p)
            let newP = p - 1
            let coeffStr = newC == 1.0 ? "" : (newC == -1.0 ? "-" : "\(Int(newC))")
            return newP == 0 ? coeffStr : newP == 1 ? "\(coeffStr)x" : "\(coeffStr)x^\(newP)"
        }
        
        return nil
    }
        
    private func integ(_ term: String) -> String? {
        let t = term.trimmingCharacters(in: .whitespaces)
        if let c = Double(t) { return "\(Int(c))x" }
        let map: [String: String] = ["sin(x)": "-cos(x)", "cos(x)": "sin(x)", "e^x": "e^x", "1/x": "ln|x|"]
        if let integ = map[t] { return integ }
            
        let regex = try? NSRegularExpression(pattern: "^([+-]?\\d*\\.?\\d*)x\\^?(\\d*)$")
        if let match = regex?.firstMatch(in: t, range: NSRange(t.startIndex..., in: t)),
            let coeffRange = Range(match.range(at: 1), in: t),
            let powRange = Range(match.range(at: 2), in: t) {
            let cStr = String(t[coeffRange])
            let c = cStr.isEmpty ? 1.0 : Double(cStr) ?? 1.0
            let p = Int(String(t[powRange])) ?? 1
            if p == -1 { return "\(Int(c))ln|x|" }
            let newP = p + 1
            let newC = c / Double(newP)
            let newCStr = newC == 1.0 ? "" : (newC == -1.0 ? "-" : "\(newC)")
            return "\(newCStr)x^\(newP)"
        }
        return nil
    }
}
