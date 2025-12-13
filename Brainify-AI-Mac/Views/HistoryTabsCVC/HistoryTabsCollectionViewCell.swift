//
//  HistoryTabsCollectionViewCell.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 28/11/2025.
//

import Cocoa

class HistoryTabsCollectionViewCell: NSCollectionViewItem {

    static var identifier = NSUserInterfaceItemIdentifier("HistoryTabsCollectionViewCell")
    
    @IBOutlet weak var tabTitleLabel: NSTextField!
    @IBOutlet weak var tabIcon: NSImageView!
    @IBOutlet weak var backgroundBox: NSBox!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabIcon.contentTintColor = .textColor
        tabTitleLabel.textColor = .textColor
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundBox.cornerRadius = isSelected ? 10 : 0
            backgroundBox.fillColor = isSelected ? .brand : .clear
            tabTitleLabel.textColor = isSelected ? .white : .labelColor
            tabIcon.contentTintColor = isSelected ? .white : .textColor
        }
    }
    
    func configure(with title: String, icon: NSImage) {
        tabTitleLabel.stringValue = title.localized()
        tabIcon.image = icon
    }
}
