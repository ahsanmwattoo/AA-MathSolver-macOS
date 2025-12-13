//
//  CustomMenuItemView.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 01/12/2025.
//

import Cocoa

class CustomMenuItemView: NSView {
    private let label = NSTextField()
    var title: String = "" { didSet { label.stringValue = title } }
    var isHovered = false { didSet { needsDisplay = true } }
    var isSelected = false { didSet { needsDisplay = true } }
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        wantsLayer = true
        layer?.cornerRadius = 8
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isBezeled = false
        label.isEditable = false
        label.drawsBackground = false
        label.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = .labelColor
        label.alignment = .left
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
        
        let area = NSTrackingArea(rect: .zero,
                                  options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
                                  owner: self)
        addTrackingArea(area)
    }
    
    override func updateTrackingAreas() {
        trackingAreas.forEach { removeTrackingArea($0) }
        let area = NSTrackingArea(rect: bounds,
                                  options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
                                  owner: self)
        addTrackingArea(area)
    }
    
    override func mouseEntered(with event: NSEvent) { isHovered = true }
    override func mouseExited(with event: NSEvent) { isHovered = false }
    
    
    override func draw(_ dirtyRect: NSRect) {
        // System ka blue highlight ko ignore karo — humara custom draw karo
        if isSelected {
            // Exact Figma purple (RGB: 139, 92, 246)
            let purple = NSColor(red: 139/255.0, green: 92/255.0, blue: 246/255.0, alpha: 1.0)
            purple.setFill()
            bounds.fill()
            label.textColor = .white
        } else if isHovered {
            NSColor.black.withAlphaComponent(0.08).setFill()  // light gray hover
            bounds.fill()
            label.textColor = .labelColor
        } else {
            NSColor.clear.setFill()
            label.textColor = .labelColor
        }
    }
}
