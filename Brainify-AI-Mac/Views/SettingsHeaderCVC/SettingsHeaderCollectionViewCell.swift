//
//  SettingsHeaderCollectionViewCell.swift
//  EmoTalk
//
//  Created by Macbook Pro on 15/10/2025.
//

import Cocoa

class SettingsHeaderCollectionViewCell: NSView {
    
    static let Identifier = NSUserInterfaceItemIdentifier("SettingsHeaderCollectionViewCell")
    
    private let titleLabel: NSTextField = {
        let label = NSTextField(labelWithString: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = NSFont.boldSystemFont(ofSize: 14)
        label.textColor = .labelColor
        label.alignment = .left
        label.isEditable = false
        label.isSelectable = false
        label.isBezeled = false
        return label
    }()
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func configure(with title: String) {
        titleLabel.stringValue = title.localized()
    }
}
