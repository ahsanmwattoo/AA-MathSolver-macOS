//
//  NSBox + Ext.swift
//  EmoTalk
//
//  Created by Macbook Pro on 10/10/2025.
//

import Foundation
import Cocoa

extension NSView {
    
    @IBInspectable var cRadius: CGFloat {
        get {
            return layer?.cornerRadius ?? 0
        }
        
        set {
            wantsLayer = true
            layer?.cornerRadius = newValue
        }
    }
}

extension NSView {
    func asImage() -> NSImage? {
        guard let bitmapRep = bitmapImageRepForCachingDisplay(in: bounds) else { return nil }
        cacheDisplay(in: bounds, to: bitmapRep)
        let image = NSImage(size: bounds.size)
        image.addRepresentation(bitmapRep)
        return image
    }
    
    func addTapGestureRecognizer(target: Any, action: Selector) {
        wantsLayer = true
        let tapGestureRecognizer = NSClickGestureRecognizer(target: target, action: action)
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    func renameChat(chatName: String, completion: @escaping (String) -> Void) {
        guard let window else { return }
        let renameAlert = NSAlert()
        
        let yesButton = renameAlert.addButton(withTitle: "Confirm")
        let noButton = renameAlert.addButton(withTitle: "Cancel")
        
        // Ensure neither button is styled as the default
        yesButton.keyEquivalent = "" // Removes default button behavior
        noButton.keyEquivalent = "" // Removes default button behavior
        
        renameAlert.messageText = "Rename Chat?"
        renameAlert.informativeText = "Are you sure to rename this chat?"
        let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        txt.stringValue = chatName
        txt.focusRingType = .none
        renameAlert.accessoryView = txt
        renameAlert.beginSheetModal(for: window) { response in
            if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
                guard !txt.stringValue.isEmpty else { return }
                completion(txt.stringValue)
            }
        }
    }
    
    func showDeleteAlert(messageText: String, informativeText: String, completion: @escaping(Bool) -> Void) {
        guard let window else { return }
        let alert = NSAlert()
        alert.messageText = messageText
        alert.informativeText = informativeText
        alert.addButton(withTitle: "Confirm")
        alert.addButton(withTitle: "Cancel")
        alert.beginSheetModal(for: window) { response in
            let result = response == .alertFirstButtonReturn
            completion(result)
        }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

import Cocoa

extension NSView {
    /// Adds a dashed border with rounded corners
    /// Works perfectly on macOS 12, 13, 14, 15 — no crash, no warning
    func addDashedBorder(pattern: [NSNumber] = [5, 5],
                         radius: CGFloat,
                         color: NSColor = .brand,
                         lineWidth: CGFloat = 1.0) {
        
        layer?.sublayers?.filter { $0.name == "DashedBorderLayer" }.forEach { $0.removeFromSuperlayer() }
        
        wantsLayer = true
        
        let borderLayer = CAShapeLayer()
        borderLayer.name = "DashedBorderLayer"
        borderLayer.frame = bounds
        borderLayer.fillColor = nil
        borderLayer.strokeColor = color.cgColor
        borderLayer.lineWidth = lineWidth
        borderLayer.lineDashPattern = pattern
        borderLayer.lineCap = .round
        borderLayer.lineJoin = .round
        
        // Yeh line har macOS version pe 100% safe hai (macOS 10.0+)
        let rect = bounds.insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
        borderLayer.path = CGPath(roundedRect: rect,
                                  cornerWidth: radius,
                                  cornerHeight: radius,
                                  transform: nil)
        
        layer?.addSublayer(borderLayer)
    }
}


