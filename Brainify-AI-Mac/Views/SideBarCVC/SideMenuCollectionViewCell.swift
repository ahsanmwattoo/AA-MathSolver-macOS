//
//  SideMenuCollectionViewCell.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 26/11/2025.
//

import Cocoa

class SideMenuCollectionViewCell: NSCollectionViewItem {

    static var identifier = NSUserInterfaceItemIdentifier("SideMenuCollectionViewCell")
    
    @IBOutlet weak var backgroundBox: NSBox!
    @IBOutlet weak var imageIcon: NSImageView!
    @IBOutlet weak var titleLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageIcon.contentTintColor = .textColor
        titleLabel.textColor = .textColor
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundBox.cornerRadius = isSelected ? 10 : 0
            backgroundBox.fillColor = isSelected ? .brand : .clear
            titleLabel.textColor = isSelected ? .white : .labelColor
            imageIcon.contentTintColor = isSelected ? .white : .textColor
        }
    }
    
    func configure(with title: String, icon: NSImage) {
        titleLabel.stringValue = title.localized()
        imageIcon.image = icon
    }
}
