//
//  UserResultTableCellView.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 01/12/2025.
//

import Cocoa

class UserResultTableCellView: NSTableCellView {

    static let identifier = NSUserInterfaceItemIdentifier("UserResultTableCellView")

    @IBOutlet weak var problemLabel: NSTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        problemLabel.stringValue = "Problem".localized()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        problemLabel.stringValue = "Problem".localized()
    }
    
    func configure(with message: Message) {
        textField?.stringValue = message.content
    }
}
