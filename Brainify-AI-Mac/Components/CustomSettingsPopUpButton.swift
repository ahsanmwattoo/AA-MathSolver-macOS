//
//  CustomSettingsPopUpButton.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 30/11/2025.
//
import Cocoa

class CustomSettingsPopUpButton: NSPopUpButton, NSMenuDelegate {
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        isBordered = false
        focusRingType = .none
        font = NSFont.systemFont(ofSize: 13, weight: .medium)
        
        wantsLayer = true
        layer?.cornerRadius = 10
        layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    func configure(with options: [String], selected: String) {
        removeAllItems()
        
        let menu = NSMenu() // CustomMenu use karo
        menu.autoenablesItems = false
        
        for option in options {
            let item = NSMenuItem()
            item.title = option
            item.target = self
            item.action = #selector(menuItemSelected(_:))
            
            let view = CustomMenuItemView(frame: NSRect(x: 0, y: 0, width: 200, height: 36))
            view.title = option
            view.isSelected = (option == selected)
            item.view = view
            
            menu.addItem(item)
        }
        
        self.menu = menu
        
        DispatchQueue.main.async {
            self.selectItem(withTitle: selected)
            self.updateTitleDisplay(selected)
        }
    }
    @objc private func menuItemSelected(_ sender: NSMenuItem) {
        guard let menu = menu else { return }
        
        // Reset sab
        for item in menu.items {
            (item.view as? CustomMenuItemView)?.isSelected = false
        }
        
        // Selected set karo
        (sender.view as? CustomMenuItemView)?.isSelected = true
        
        updateTitleDisplay(sender.title)
        sendAction(action, to: target)
        
        // Menu close karo after selection
        menu.cancelTracking()
    }
    
    private func updateTitleDisplay(_ title: String) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 13, weight: .medium),
            .foregroundColor: NSColor.white,
            .paragraphStyle: paragraph
        ]
        
        attributedTitle = NSAttributedString(string: "  \(title)  ", attributes: attrs)
    }

}
