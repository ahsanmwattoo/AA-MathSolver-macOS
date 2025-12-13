//
//  ArithmeticCalculatorViewController.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 01/12/2025.
//

import Cocoa

class ArithmeticCalculatorViewController: BaseViewController {

    static var identifier: String { "ArithmeticCalculatorViewController" }
    
    @IBOutlet var textField: PlaceHolderTextView!
    @IBOutlet weak var hideableStack: NSStackView!
    
    @IBOutlet weak var solveLabel: NSTextField!
    private var currentExpression: String = "" {
        didSet {
            updateDisplay()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func didChangeLanguage() {
        DispatchQueue.main.async {
            [weak self] in
            guard let self else { return }
            textField.placeholderString = "Type Your Equation Here...".localized()
            solveLabel.stringValue = "Solve".localized()
        }
    }
    
    func setupUI() {
        textField.backgroundColor = .clear
        textField.isEditable = true
        textField.isSelectable = true
        textField.font = .systemFont(ofSize: 22, weight: .bold)
        textField.placeholderString = "Type Your Equation Here...".localized()
        textField.placeholderTextColor = .secondaryText
    }
    
    private func updateDisplay() {
        textField.string = currentExpression.isEmpty ? "0" : currentExpression
    }
}
