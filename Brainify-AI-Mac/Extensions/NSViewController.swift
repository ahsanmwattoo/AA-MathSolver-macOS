//
//  NSViewController + Ext.swift
//  EmoTalk
//
//  Created by Macbook Pro on 13/10/2025.
//

import Foundation
import Cocoa

extension NSViewController {
    func share(image: NSImage) {
        let sharingServicePicker = NSSharingServicePicker(items: [image])
        sharingServicePicker.show(relativeTo: view.bounds, of: view, preferredEdge: .minY)
    }
}

extension NSViewController {
    
//    func addChildToNavigation(_ controller: NSViewController) {
//        addChild(controller)
//
//        var initialFrame = view.bounds
//        initialFrame.origin.x = view.bounds.width
//        controller.view.frame = initialFrame
//
//        let finalFrame = view.bounds
//
//        view.addSubview(controller.view)
//        controller.view.autoresizingMask = [.width, .height]
//
//        NSAnimationContext.runAnimationGroup { context in
//            context.duration = 0.25
//            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//            controller.view.animator().frame = finalFrame
//        }
//    }
    
    func addChildToNavigation(_ controller: NSViewController) {
        addChild(controller)
        
        var initialFrame = view.bounds
        initialFrame.origin.x = view.bounds.width
        controller.view.frame = initialFrame
        
        let finalFrame = view.bounds
        
        view.addSubview(controller.view)
        controller.view.autoresizingMask = [.width, .height]
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            controller.view.animator().frame = finalFrame
        }
    }
    
//    func addChildToNavigation(_ controller: NSViewController) {
//        addChild(controller)
//
//        let finalFrame = view.bounds
//        controller.view.frame = finalFrame
//        controller.view.alphaValue = 0.0 // Start fully transparent
//        controller.view.autoresizingMask = [.width, .height]
//
//        view.addSubview(controller.view)
//
//        NSAnimationContext.runAnimationGroup { context in
//            context.duration = 0.25
//            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//            controller.view.animator().alphaValue = 1.0 // Fade in to fully opaque
//        }
//    }
    
//    func removeChildFromNavigation() {
//        let finalFrame = view.frame.offsetBy(dx: view.bounds.width, dy: 0)
//
//        NSAnimationContext.runAnimationGroup({ [weak self] context in
//            guard let self else { return }
//            context.duration = 0.25
//            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//            view.animator().frame = finalFrame
//        }, completionHandler: { [weak self] in
//            guard let self else { return }
//            view.removeFromSuperview()
//            removeFromParent()
//        })
//    }
    func removeChildFromNavigation() {
        // Set the view's alpha to 1 before starting the animation (in case it's already changed)
        view.alphaValue = 1.0
        
        NSAnimationContext.runAnimationGroup({ [weak self] context in
            guard let self else { return }
            context.duration = 0.25
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            // Fade out the view by animating its alpha value to 0
            view.animator().alphaValue = 0
        }, completionHandler: { [weak self] in
            guard let self else { return }
            
            // Remove the view after it becomes fully transparent
            view.removeFromSuperview()
            removeFromParent()
        })
    }

    func openURLinExternalBrowser(url: String) {
        guard let url = URL(string: url) else {
            return
        }
        
        NSWorkspace.shared.open(url)
    }
}

extension NSViewController {
    func countdownTimer(
        initialTime: TimeInterval,
        hoursLabel: NSTextField,
        minutesLabel: NSTextField,
        secondsLabel: NSTextField
    ) -> Timer {
        var remainingTime = initialTime
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if remainingTime > 0 {
                remainingTime -= 1
                let (hours, minutes, seconds) = self.minutesAndSecondsTimer(from: remainingTime)
                hoursLabel.stringValue = String(format: "%02d", hours)
                minutesLabel.stringValue = String(format: "%02d", minutes)
                secondsLabel.stringValue = String(format: "%02d", seconds)
                
                // Post notification for timer update
                NotificationCenter.default.post(
                    name: Notification.Name("TimerUpdate"),
                    object: nil,
                    userInfo: [
                        "hours": hours,
                        "minutes": minutes,
                        "seconds": seconds
                    ]
                )
            } else {
                // Timer reached 0, reset to initial time
                remainingTime = initialTime
                
                // Post notification for timer completion
                NotificationCenter.default.post(
                    name: Notification.Name("TimerComplete"),
                    object: nil
                )
            }
        }
        
        return timer
    }
    
    private func minutesAndSecondsTimer(from time: TimeInterval) -> (Int, Int, Int) {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = (Int(time) % 3600) % 60
        return (hours, minutes, seconds)
    }
}

extension NSViewController {
    func renameChat(chatName: String, completion: @escaping (String) -> Void) {
        let renameAlert = NSAlert()
        
        let yesButton = renameAlert.addButton(withTitle: "Confirm".localized())
        let noButton = renameAlert.addButton(withTitle: "Cancel".localized())
        
        // Ensure neither button is styled as the default
        yesButton.keyEquivalent = "" // Removes default button behavior
        noButton.keyEquivalent = "" // Removes default button behavior
        
        renameAlert.messageText = "Rename Chat?".localized()
        renameAlert.informativeText = "Are you sure to rename this chat?".localized()
        let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        txt.stringValue = chatName
        txt.focusRingType = .none
        renameAlert.accessoryView = txt
        let response: NSApplication.ModalResponse = renameAlert.runModal()
        if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
            guard !txt.stringValue.isEmpty else { return }
            completion(txt.stringValue)
        }
    }
    
    func showDeleteAlert(messageText: String, informativeText: String, completion: @escaping(Bool) -> Void) {
        guard let window = view.window else { return }
        let alert = NSAlert()
        alert.messageText = messageText
        alert.informativeText = informativeText
        alert.addButton(withTitle: "Confirm".localized())
        alert.addButton(withTitle: "Cancel".localized())
        alert.beginSheetModal(for: window) { response in
            let result = response == .alertFirstButtonReturn
            completion(result)
        }
        
    }
}




extension NSView {
    func takeScreenshot() -> NSImage? {
        // Create a bitmap representation of the view
        guard let bitmapRep = self.bitmapImageRepForCachingDisplay(in: self.bounds) else { return nil }
        NSColor.black.setFill()
        self.cacheDisplay(in: self.bounds, to: bitmapRep)
        let image = NSImage(size: bounds.size)
        image.addRepresentation(bitmapRep)
        
        return image
    }
}


extension NSViewController {
    func addChildViewControllerWithSlideAnimation(_ controller: NSViewController) {
        addChild(controller)
        
        let initialFrame = view.bounds.offsetBy(dx: -view.bounds.width, dy: 0)
        let finalFrame = view.bounds
        
        controller.view.frame = initialFrame
        view.addSubview(controller.view)
        controller.view.autoresizingMask = [.width, .height]
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.5
            controller.view.animator().frame = finalFrame
        }
    }
}
