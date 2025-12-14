//
//  FormulaCell.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 29/11/2025.
//

import Cocoa
import SwiftMath

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
                numberLabel.font = NSFont.systemFont(ofSize: 16, weight: .medium)
                numberLabel.textColor = .brand
                
                let cleanName = formula.name.localized()
                    .replacingOccurrences(of: ":", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                let nameLabel = NSTextField(wrappingLabelWithString: cleanName)
                nameLabel.font = NSFont.systemFont(ofSize: 16, weight: .semibold)
                nameLabel.textColor = .brand
                
                let headerStack = NSStackView(views: [numberLabel, nameLabel])
                headerStack.spacing = 8
                headerStack.alignment = .centerY
                
                // SwiftMath Label
                let mathLabel = MTMathUILabel()
                mathLabel.latex = formula.formula
                mathLabel.fontSize = 17
                mathLabel.textColor = NSColor.labelColor
                mathLabel.labelMode = .display
                mathLabel.textAlignment = .left
                mathLabel.contentInsets = NSEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
                
                DispatchQueue.main.async { [weak mathLabel, weak self] in
                    guard let mathLabel = mathLabel, let self = self else { return }
                    
                    mathLabel.layout()
                    
                    let fittingHeight = mathLabel.fittingSize.height
                    
                    if fittingHeight > 0 {
                        mathLabel.constraints.forEach { $0.isActive = false }
                        
                        let heightConstraint = mathLabel.heightAnchor.constraint(equalToConstant: fittingHeight)
                        heightConstraint.priority = .required
                        heightConstraint.isActive = true
                    } else {
                        mathLabel.latex = "\\text{Error parsing formula}"
                        mathLabel.layout()
                    }
                    self.layoutSubtreeIfNeeded()
                }
                // Indent
                let indentView = NSView()
                indentView.translatesAutoresizingMaskIntoConstraints = false
                indentView.widthAnchor.constraint(equalToConstant: 5).isActive = true
                
                let indentedStack = NSStackView(views: [indentView, mathLabel])
                indentedStack.spacing = 0
                indentedStack.alignment = .top
                
                // Vertical Stack
                let vStack = NSStackView(views: [headerStack, indentedStack])
                vStack.orientation = .vertical
                vStack.spacing = 14
                vStack.alignment = .leading
                
                formulasStackView.addArrangedSubview(vStack)
            }
            
            formulasStackView.isHidden = false
            formulaStackBottomConstraint?.constant = -20
            
            // Extra layout pass
            DispatchQueue.main.async {
                self.layoutSubtreeIfNeeded()
            }
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
