//
//  NSBOX.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 26/11/2025.
//

import AppKit

extension NSBox {
    
    /// Box ke andar left → right full gradient background laga do
    /// Example: myBox.applyGradientFill(colors: [.red, .orange, .yellow, .green, .blue])
    func applyGradientFill(colors: [NSColor]) {
        guard colors.count >= 2 else { return }
        
        wantsLayer = true
        boxType = .custom
        borderWidth = 0
        
        // Purana gradient hatao agar ho toh
        layer?.sublayers?.removeAll { $0 is CAGradientLayer }
        
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint   = CGPoint(x: 1.0, y: 0.5)
        
        // Agar tumhe locations bhi custom dena hai toh de sakte ho, warna equal spacing
        if colors.count > 2 {
            let step = 1.0 / CGFloat(colors.count - 1)
            gradient.locations = (0..<colors.count).map { NSNumber(value: Float($0) * Float(step)) }
        }
        
        /*layer?.insertSublayer(gradient, at: 0)*/  // sabse neeche background mein
    }
}

extension NSBox {
    
    /// Ek line mein NSBox ka border gradient kar do
    func makeBorderGradient() {
        wantsLayer = true
        boxType = .custom
        borderWidth = 0
        cornerRadius = 18
        fillColor = .background   // ya jo background chahiye wo rakh do
        
        let g = CAGradientLayer()
        g.frame = bounds
        g.colors = [NSColor(hex: "#E43131").cgColor,
                    NSColor(hex: "#953CF5").cgColor]
        g.startPoint = CGPoint(x: 0, y: 0.5)
        g.endPoint   = CGPoint(x: 1, y: 0.5)
        
        let mask = CAShapeLayer()
        let path = CGMutablePath()
        path.addRoundedRect(in: bounds, cornerWidth: 18, cornerHeight: 18)
        path.addRoundedRect(in: bounds.insetBy(dx: 2, dy: 2), cornerWidth: 16, cornerHeight: 16)
        mask.path = path
        mask.fillRule = .evenOdd
        
        g.mask = mask
        layer?.addSublayer(g)
    }
}
