//
//  OfferBox.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 27/11/2025.
//

import Cocoa

class OfferBox: NSView {
    var gradientColors: [NSColor] = [
        .background,
        .fillColor2,
        .fillColor3,
        .fillColor2,
        .background
    ]
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let gradient = NSGradient(colors: gradientColors)!
        gradient.draw(in: bounds, angle: 45)
        
    }
    
    // Ye bahut zaroori hai — appearance change hone par redraw karna
    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        setNeedsDisplay(NSRect())
    }
}
