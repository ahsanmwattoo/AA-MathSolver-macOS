//
//  AIMathResultProblemCellView.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 12/12/2025.
//

import Cocoa
import SwiftUI

class AIMathResultProblemCellView: NSTableCellView {
    
    static let identifier = NSUserInterfaceItemIdentifier("AIMathResultProblemCellView")

    @IBOutlet weak var problemLabel: NSTextField!
    @IBOutlet weak var textView: NSTextField!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        problemLabel.stringValue = "Problem".localized()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        problemLabel.stringValue = "Problem".localized()
    }
    
    func configure(with problemText: String) {
        imageView?.isHidden = true
        textView?.isHidden = false
        textView?.stringValue = problemText
    }
    
    func configure(with problemImage: NSImage) {
        imageView?.isHidden = false
        textView?.isHidden = true
        imageView?.image = problemImage
    }
}
