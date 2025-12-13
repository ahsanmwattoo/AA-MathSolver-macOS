//
//  CustomMenu.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 01/12/2025.
//

import Cocoa

class CustomMenu: NSMenu, NSMenuDelegate {
    
    override init(title: String) {
        super.init(title: title)
        setupMenu()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupMenu()
    }
    
    private func setupMenu() {
        showsStateColumn = false
        allowsContextMenuPlugIns = false  // ← Yeh menu pe lagao, item pe nahi
        autoenablesItems = false
    }
    
    // Hover ke liye delegate
    func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
        // Reset sabka highlight
        for mi in items {
            if let view = mi.view as? CustomMenuItemView {
                view.isHovered = false
                view.isSelected = false  // selected state maintain karo
            }
        }
        
        // Sirf current item ko hover banao
        if let item = item, let view = item.view as? CustomMenuItemView {
            view.isHovered = true
        }
    }
}
