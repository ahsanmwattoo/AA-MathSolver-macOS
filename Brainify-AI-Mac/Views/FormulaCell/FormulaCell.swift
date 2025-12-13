//
//  FormulaCell.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 29/11/2025.
//

import Cocoa

class FormulaCell: NSTableCellView {
    
    static var identifier = "FormulaCell"
    
    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var imageIcon: NSImageView!
    
    private var formulasStackView: NSStackView!
    var formulaStackBottomConstraint: NSLayoutConstraint?
        
        override func awakeFromNib() {
            super.awakeFromNib()
            setupStackView()
        }
        
    override func prepareForReuse() {
            super.prepareForReuse()
            hideFormulas()
            formulasStackView?.arrangedSubviews.forEach { $0.removeFromSuperview() }
        }
    
    private func setupStackView() {
        
            if formulasStackView != nil { return }
            
            formulasStackView = NSStackView()
            formulasStackView.orientation = .vertical
            formulasStackView.spacing = 14
            formulasStackView.alignment = .leading
            formulasStackView.distribution = .fill
            formulasStackView.translatesAutoresizingMaskIntoConstraints = false
            
            self.addSubview(formulasStackView)
            formulaStackBottomConstraint = formulasStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
            NSLayoutConstraint.activate([
                formulasStackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
                formulasStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
                formulasStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
                formulaStackBottomConstraint!
            ])
        }
        // Formulas dikhao
    func showFormulas(_ formulas: [Formula]) {
            setupStackView()
            
            formulasStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            for (index, formula) in formulas.enumerated() {
                let numberLabel = NSTextField(labelWithString: "\(index + 1).")
                numberLabel.font = NSFont.systemFont(ofSize: 16)
                numberLabel.textColor = .brand
                let name = formula.name.localized()
                let cleanName = name.replacingOccurrences(of: ":", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                let nameLabel = NSTextField(wrappingLabelWithString: cleanName)
                nameLabel.font = NSFont.systemFont(ofSize: 16)
                nameLabel.textColor = .brand
                
                let hStack = NSStackView(views: [numberLabel, nameLabel])
                hStack.spacing = 2
                hStack.alignment = .centerY
                hStack.distribution = .fill
                
                let formulaLabel = NSTextField(wrappingLabelWithString: formula.formula.prettyText())
                formulaLabel.font = NSFont.systemFont(ofSize: 16)
                formulaLabel.textColor = .labelColor
                formulaLabel.maximumNumberOfLines = 0
                
                let vStack = NSStackView(views: [hStack, formulaLabel])
                vStack.orientation = .vertical
                vStack.spacing = 6
                vStack.alignment = .leading
                
                formulasStackView.addArrangedSubview(vStack)
            }
        
            formulasStackView.isHidden = false
        formulaStackBottomConstraint?.constant = -20
            self.setNeedsDisplay(self.bounds)
        }
        
        func hideFormulas() {
            formulasStackView?.isHidden = true
            formulaStackBottomConstraint?.constant = -10
        }
    }

extension NSTextField {
    convenience init(wrappingLabelWithString string: String) {
        self.init(labelWithString: string)
        self.lineBreakMode = .byWordWrapping
        self.maximumNumberOfLines = 0
        self.cell?.isScrollable = false
        self.cell?.wraps = true
    }
}
