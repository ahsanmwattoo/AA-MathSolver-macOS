//
//  UserTableCellView.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 01/12/2025.
//

import Cocoa

class UserTableCellView: NSTableCellView {

    static let identifier = NSUserInterfaceItemIdentifier("UserTableCellView")
    
    func configure(with message: Message) {
        textField?.stringValue = message.content
    }
}
