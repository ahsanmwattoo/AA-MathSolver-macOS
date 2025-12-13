//
//  BasicCalculatorViewController.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 29/11/2025.
//

import Cocoa

protocol BasicCalculatorDelegate: AnyObject {
    func calculator(_ calculator: BasicCalculatorViewController, didUpdateExpression text: String)
    func calculatorDidClearText(_ calculator: BasicCalculatorViewController)
}

class BasicCalculatorViewController: BaseViewController {
    
    static var identifier = "BasicCalculatorViewController"
    
    @IBOutlet var textField: PlaceHolderTextView!
    @IBOutlet weak var hideableStack: NSStackView!
    @IBOutlet weak var clearButton: NSButton!
    @IBOutlet weak var solveLabel: NSTextField!
    
    private var currentExpression: String = "" {
        didSet {
            updateDisplay()
            updateClearButtonTitle()
        }
    }
    
    var isPopupMode: Bool = false  {
        didSet {
            hideAbleStackView()
        }
    }
    
    private var isResultShown = false
    weak var delegate: BasicCalculatorDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        resetCalculator()
        textField.delegate = self
        DispatchQueue.main.async {
                self.view.window?.makeFirstResponder(self)
        }
    }
    
    override func didChangeLanguage() {
        DispatchQueue.main.async {
            [weak self] in
            guard let self else { return }
            textField.placeholderString = "Type Your Equation Here...".localized()
            solveLabel.stringValue = "Solve".localized()
            updateClearButtonTitle()
        }
    }
    
    func setupUI() {
        textField.backgroundColor = .clear
        textField.isEditable = true
        textField.isSelectable = true
        textField.font = .systemFont(ofSize: 22, weight: .bold)
        textField.placeholderString = "Type Your Equation Here...".localized()
        textField.placeholderTextColor = .secondaryText
        updateClearButtonTitle()
    }
    
    private func resetCalculator() {
        currentExpression = ""
        isResultShown = false
        updateDisplay()
        updateClearButtonTitle()
    }
    
    func hideAbleStackView() {
        if isPopupMode {
            DispatchQueue.main.async {
                [weak self] in
                guard let self else { return }
                hideableStack?.isHidden = true
            }
        } else {
            hideableStack?.isHidden = false
        }
    }
    
    @IBAction func numberPressed(_ sender: NSButton) {
        guard let digit = sender.title.first else { return }
        
        if isResultShown {
            currentExpression = ""
            isResultShown = false
        }
        delegate?.calculator(self, didUpdateExpression: sender.title)
        currentExpression += String(digit)
    }
    
    @IBAction func decimalPressed(_ sender: NSButton) {
        if isResultShown {
            currentExpression = "0."
            isResultShown = false
            return
        }
        
        let components = currentExpression.components(separatedBy: CharacterSet(charactersIn: "+-×÷("))
        let lastPart = components.last ?? ""
        
        if lastPart.isEmpty || !lastPart.contains(".") {
            if lastPart.isEmpty && (currentExpression.isEmpty || " +-×÷(".contains(currentExpression.last!)) {
                currentExpression += "0."
            } else {
                currentExpression += "."
            }
        }
        delegate?.calculator(self, didUpdateExpression: sender.title)
    }
    
    @IBAction func operationPressed(_ sender: NSButton) {
        guard let op = sender.title.first else { return }
        let opStr = String(op)
        
        if isResultShown {
            isResultShown = false
        }
        
        if currentExpression.isEmpty {
            if opStr == "-" {
                currentExpression = "-"
            }
            return
        }
        
        if let last = currentExpression.last, "+-×÷".contains(last) {
            currentExpression.removeLast()
        }
        
        currentExpression += opStr
        delegate?.calculator(self, didUpdateExpression: sender.title)
    }
    
    @IBAction func equalsPressed(_ sender: NSButton) {
        if isPopupMode {
            currentExpression += "="
            delegate?.calculator(self, didUpdateExpression: "=")
        } else {
            calculateResult()
        }
    }
    
    @IBAction func clearPressed(_ sender: NSButton) {
        if clearButton.title == "AC" || hideableStack.isHidden {
            resetCalculator()
        } else {
            currentExpression.removeLast()
        }
        delegate?.calculatorDidClearText(self)
    }
    
    private func updateClearButtonTitle() {
        if hideableStack.isHidden {
            clearButton.title = "AC"
        } else {
            clearButton.title = currentExpression.isEmpty && !isResultShown ? "AC" : "AC"
        }
    }
    
    @IBAction func leftParenthesisPressed(_ sender: NSButton) {
        if isResultShown {
            currentExpression = ""
            isResultShown = false
        }
        currentExpression += "("
        delegate?.calculator(self, didUpdateExpression: sender.title)
    }
    
    @IBAction func rightParenthesisPressed(_ sender: NSButton) {
        if isResultShown {
            currentExpression = ""
            isResultShown = false
        }
        currentExpression += ")"
        delegate?.calculator(self, didUpdateExpression: sender.title)
    }
    
    
    @IBAction func didTapSolve(_ sender: Any) {
        calculateResult()
    }
    
    private func calculateResult() {
        guard !currentExpression.isEmpty else { return }
        
        let result = evaluateExpressionSafely(currentExpression)
        
        if result == "Invalid Expression" || result == "Error" {
            showInvalidExpressionFeedback()
            return
        }
        
        textField.string = result
        currentExpression = result
        isResultShown = true
        clearButton.title = "AC"
    }
    
    private func showInvalidExpressionFeedback() {
        textField.string = "Invalid Expression".localized()
        textField.textColor = NSColor.systemRed.withAlphaComponent(0.9)
        
        let animation = CABasicAnimation(keyPath: "position.x")
        animation.fromValue = textField.layer?.position.x ?? 0
        animation.toValue = (textField.layer?.position.x ?? 0) + 10
        animation.duration = 0.08
        animation.repeatCount = 4
        animation.autoreverses = true
        
        textField.layer?.add(animation, forKey: "shake")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            if self?.isResultShown == false {
                self?.textField.textColor = .labelColor
                self?.updateDisplay()
            }
        }
    }
    
    private func updateDisplay() {
        if !isPopupMode {
            textField.string = currentExpression.isEmpty ? "" : currentExpression
        }
    }

    private func clearAll() {
        currentExpression = ""
        updateDisplay()
        updateClearButtonTitle()
    }
    
    private func evaluateExpression(_ expression: String) -> String {
        let cleanExpr = expression
            .replacingOccurrences(of: "×", with: "*")
            .replacingOccurrences(of: "÷", with: "/")
            .replacingOccurrences(of: ",", with: "")
        
        guard !cleanExpr.isEmpty else { return "0" }
        
        do {
            let exp = NSExpression(format: cleanExpr)
            if let result = exp.expressionValue(with: nil, context: nil) as? NSNumber {
                let doubleValue = result.doubleValue
                
                if doubleValue == -0 { return "0" }
                
                if doubleValue.truncatingRemainder(dividingBy: 1) == 0 {
                    return String(Int(doubleValue))
                }
                
                let formatter = NumberFormatter()
                formatter.minimumFractionDigits = 0
                formatter.maximumFractionDigits = 8
                return formatter.string(from: NSNumber(value: doubleValue)) ?? "\(doubleValue)"
            }
        }
        
        return "Error"
    }
    
    private func insertImplicitMultiplication(_ expr: String) -> String {
        var result = ""
        let chars = Array(expr)
        
        for i in 0..<chars.count {
            let current = chars[i]
            result.append(current)
            
            if i + 1 >= chars.count { continue }
            let next = chars[i + 1]
            
            if current == ")" && (next.isNumber || next == "(") {
                result.append("*")
            }
            else if (current.isNumber || current == ".") && next == "(" {
                result.append("*")
            }
        }
        
        return result
    }

    private func evaluateExpressionSafely(_ expression: String) -> String {
        var cleanExpr = expression
            .replacingOccurrences(of: "×", with: "*")
            .replacingOccurrences(of: "÷", with: "/")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanExpr.isEmpty else { return "0" }
        
        cleanExpr = insertImplicitMultiplication(cleanExpr)
        
        if hasUnbalancedParentheses(cleanExpr) || hasInvalidDecimalUsage(cleanExpr) || hasConsecutiveOperators(cleanExpr) {
            return "Invalid Expression"
        }
        
        do {
            let exp = NSExpression(format: cleanExpr)
            if let result = exp.expressionValue(with: nil, context: nil) as? NSNumber {
                let value = result.doubleValue
                if value.isInfinite || value.isNaN { return "Invalid Expression" }
                if value == -0 { return "0" }
                
                let formatter = NumberFormatter()
                formatter.maximumFractionDigits = 8
                formatter.minimumFractionDigits = 0
                formatter.numberStyle = .decimal
                return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
            }
        }
        
        return "Invalid Expression"
    }
}

extension BasicCalculatorViewController {
    private func hasUnbalancedParentheses(_ expr: String) -> Bool {
        var count = 0
        for char in expr {
            if char == "(" { count += 1 }
            else if char == ")" { count -= 1 }
            if count < 0 { return true }
        }
        return count != 0
    }

    private func hasConsecutiveOperators(_ expr: String) -> Bool {
        let operators = "+-*/"
        for i in 0..<(expr.count - 1) {
            let current = expr[expr.index(expr.startIndex, offsetBy: i)]
            let next = expr[expr.index(expr.startIndex, offsetBy: i + 1)]
            if operators.contains(current) && operators.contains(next) {
                if !(i == 0 || expr[expr.index(expr.startIndex, offsetBy: i-1)] == "(") {
                    return true
                }
            }
        }
        return false
    }

    private func hasInvalidDecimalUsage(_ expr: String) -> Bool {
        let components = expr.components(separatedBy: CharacterSet(charactersIn: "+-*/()"))
        for part in components {
            if part.filter({ $0 == "." }).count > 1 {
                return true
            }
        }
        return false
    }
}

extension BasicCalculatorViewController: NSTextViewDelegate {
    
    // Yeh method NSTextView ke liye kaam karta hai (PlaceHolderTextView agar NSTextView subclass hai toh)
    func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        
        if commandSelector == #selector(deleteBackward(_:)) ||
           commandSelector == #selector(deleteForward(_:)) {
            
            if isResultShown {
                resetCalculator()
                delegate?.calculatorDidClearText(self)
            } else if !currentExpression.isEmpty {
                currentExpression.removeLast()
                updateDisplay()
                updateClearButtonTitle()
                delegate?.calculator(self, didUpdateExpression: currentExpression)
            }
            return true // Event ko "consume" kar diya, textView khud delete na kare
        }
        
        return false // Baaki commands normally jaane do
    }
}
