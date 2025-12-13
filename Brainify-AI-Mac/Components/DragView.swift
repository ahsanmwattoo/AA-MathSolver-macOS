//
//  DragView.swift
//  EmoTalk
//
//  Created by Macbook Pro on 14/10/2025.
//

import Cocoa
import UniformTypeIdentifiers

class DragView: NSView {
    
    public var fileUrlCallback: ((URL) -> Void)?
    // MARK: - Customization Properties
    var dashColor: NSColor = .brand
    var cornerRadius: CGFloat = 22
    var dashHeight: CGFloat = 1
    var dashLength: CGFloat = 5
    var gapLength: CGFloat = 5
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([.fileURL])
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard bounds.width > dashHeight * 2 && bounds.height > dashHeight * 2 else { return }
        
        let context = NSGraphicsContext.current!.cgContext
        
        // Create rounded rectangle path
        let roundedRect = NSBezierPath(
            roundedRect: bounds.insetBy(dx: dashHeight / 2, dy: dashHeight / 2),
            xRadius: cornerRadius,
            yRadius: cornerRadius
        )
        
        // Important settings for nice dashed rounded corners
        roundedRect.lineWidth = dashHeight
        roundedRect.lineCapStyle = .round      // Makes dash ends rounded
        roundedRect.lineJoinStyle = .round     // Makes corners smooth
        
        // Set dash pattern: [dashLength, gapLength]
        dashColor.setStroke()
        roundedRect.setLineDash([dashLength, gapLength], count: 2, phase: 0)
        
        roundedRect.stroke()
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if checkIfFilesExist(sender) {
            return .copy
        }
        return []
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if checkIfFilesExist(sender) {
            if let fileURL = getFileURL(from: sender) {
                print(fileURL.pathExtension)
                if ["jpg", "png", "jpeg", "heic", "heif"].contains(fileURL.pathExtension) {
                    if let fileUrlCallback = fileUrlCallback {
                        fileUrlCallback(fileURL)
                    }
                    return true
                } else {
                    showAlertForUnsupportedFileType()
                    return false
                }
            }
        }
        return false
    }
    
    private func checkIfFilesExist(_ draggingInfo: NSDraggingInfo) -> Bool {
        guard let types = draggingInfo.draggingPasteboard.types else {
            return false
        }
        return types.contains(.fileURL)
    }
    
    private func getFileURL(from draggingInfo: NSDraggingInfo) -> URL? {
        let pasteboard = draggingInfo.draggingPasteboard
        if let data = pasteboard.data(forType: .fileURL),
           let fileURL = URL(dataRepresentation: data, relativeTo: nil) {
            return fileURL
        }
        return nil
    }
    
    private func showAlertForUnsupportedFileType() {
        let alert = NSAlert()
        alert.messageText = "Invalid File Type".localized()
        alert.informativeText = "The file type is not supported. Please upload a valid file (e.g., JPEG or PNG).".localized()
        alert.addButton(withTitle: "OK".localized())
        alert.runModal()
    }
}
