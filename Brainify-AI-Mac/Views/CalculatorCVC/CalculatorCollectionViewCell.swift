//
//  CalculatorCollectionViewCell.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 28/11/2025.
//

import Cocoa

class CalculatorCollectionViewCell: NSCollectionViewItem {
    
    static var identifier = "CalculatorCollectionViewCell"
    
    @IBOutlet weak var backgroundBox: NSBox!
    @IBOutlet weak var titleLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundBox.borderColor = isSelected ? .brand: .stroke
            titleLabel.textColor = isSelected ? .brand : .labelColor
        }
    }
}
