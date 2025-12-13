//
//  NSImage.swift
//  EmoTalk
//
//  Created by Macbook Pro on 16/10/2025.
//

import Cocoa

extension NSImage {
    func jpegData(compressionQuality: CGFloat) -> Data? {
        guard let tiffRepresentation = self.tiffRepresentation,
              let imageRep = NSBitmapImageRep(data: tiffRepresentation) else {
            return nil
        }

        let properties: [NSBitmapImageRep.PropertyKey: Any] = [.compressionFactor: compressionQuality]
        return imageRep.representation(using: .jpeg, properties: properties)
    }

    /// Creates a new NSImage from compressed JPEG data.
    func compressedJPEGImage(compressionQuality: CGFloat) -> NSImage? {
        guard let compressedData = self.jpegData(compressionQuality: compressionQuality) else {
            return nil
        }
        return NSImage(data: compressedData)
    }
    
    func toBase64(compressionQuality: CGFloat = 5.0) -> String? {
        guard let tiffData = self.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiffData),
           let data = bitmap.representation(using: .png, properties: [:]) else {
          return nil
        }
        return data.base64EncodedString()
      }
}

import AppKit

extension NSImage {
    func resizedForReplicate(maxPixelSize: CGFloat = 512, compressionQuality: CGFloat = 0.6) -> NSImage? {
        guard let tiffData = self.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        
        let originalSize = NSSize(width: bitmap.pixelsWide, height: bitmap.pixelsHigh)
        let targetSize = NSSize(width: maxPixelSize, height: maxPixelSize)
        
        // Calculate scale ratio (maintaining aspect ratio)
        let widthRatio  = targetSize.width / CGFloat(originalSize.width)
        let heightRatio = targetSize.height / CGFloat(originalSize.height)
        let scaleRatio = min(widthRatio, heightRatio)
        
        let scaledSize = NSSize(
            width: CGFloat(originalSize.width) * scaleRatio,
            height: CGFloat(originalSize.height) * scaleRatio
        )
        
        // Create final square image
        let finalImage = NSImage(size: targetSize)
        finalImage.lockFocus()
        
        // Background transparent (optional: white bhi kar sakta hai)
        NSColor.clear.set()
        NSRect(origin: .zero, size: targetSize).fill()
        
        // Center the scaled image
        let origin = NSPoint(
            x: (targetSize.width - scaledSize.width) / 2,
            y: (targetSize.height - scaledSize.height) / 2
        )
        
        let drawRect = NSRect(origin: origin, size: scaledSize)
        
        // Draw the image (best quality)
        self.draw(in: drawRect,
                  from: NSRect(origin: .zero, size: originalSize),
                  operation: .copy,
                  fraction: 1.0,
                  respectFlipped: true,
                  hints: [
                    NSImageRep.HintKey.interpolation: NSImageInterpolation.high.rawValue
                  ])
        
        finalImage.unlockFocus()
        
        // Convert to JPEG data (smaller base64 than PNG)
        guard let jpegData = finalImage.jpegData(compressionQuality: compressionQuality) else {
            return finalImage // fallback
        }
        
        return NSImage(data: jpegData)
    }
}


extension NSImage {
    func tint(color: NSColor) -> NSImage {
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return self
        }
        
        return NSImage(size: size, flipped: false) { rect in
            guard let context = NSGraphicsContext.current?.cgContext else { return false }
            
            context.clip(to: rect, mask: cgImage)
            color.setFill()
            context.fill(rect)
            
            return true
        }
    }
}
