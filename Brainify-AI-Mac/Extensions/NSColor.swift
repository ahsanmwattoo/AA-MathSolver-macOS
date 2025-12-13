//
//  NSColor.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 26/11/2025.
//


import AppKit

extension NSColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
                     .replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        
        let r, g, b, a: CGFloat
        
        if hex.count == 6 {
            r = CGFloat((rgb >> 16) & 0xFF) / 255
            g = CGFloat((rgb >> 8)  & 0xFF) / 255
            b = CGFloat(rgb & 0xFF) / 255
            a = 1.0
        } else if hex.count == 8 {
            r = CGFloat((rgb >> 24) & 0xFF) / 255
            g = CGFloat((rgb >> 16) & 0xFF) / 255
            b = CGFloat((rgb >> 8)  & 0xFF) / 255
            a = CGFloat(rgb & 0xFF) / 255
        } else {
            r = 1; g = 1; b = 1; a = 1
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}

extension NSColor {
    static func gradientColor(
        from startColor: NSColor,
        to endColor: NSColor,
        size: CGSize = CGSize(width: 1, height: 200),
        angle: CGFloat = 90
    ) -> NSColor {
        
        // Create gradient image
        let image = NSImage(size: size)
        image.lockFocus()

        let gradient = NSGradient(starting: startColor, ending: endColor)
        gradient?.draw(in: NSRect(origin: .zero, size: size), angle: angle)

        image.unlockFocus()

        // Wrap image as pattern color
        return NSColor(patternImage: image)
    }
    
    static func gradientColor(
        colors: [NSColor],
        locations: [CGFloat]? = nil,
        size: CGSize = CGSize(width: 1, height: 300),
        angle: CGFloat = 90
    ) -> NSColor {
        
        let image = NSImage(size: size)
        image.lockFocus()
        
        let gradient = NSGradient(colors: colors, atLocations: locations, colorSpace: .deviceRGB)
        gradient?.draw(in: NSRect(origin: .zero, size: size), angle: angle)
        
        image.unlockFocus()
        
        return NSColor(patternImage: image)
    }
}
