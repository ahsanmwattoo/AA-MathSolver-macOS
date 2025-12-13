//
//  LoadingWindowController.swift
//  SnapSaver-Mac
//
//  Created by MackBook Pro on 10/30/25.
//

import AppKit

final class LoadingWindowController: NSWindowController {

    private var indicator: NSProgressIndicator!

    convenience init() {
        let win = NSWindow(
            contentRect: .zero,
            styleMask: [.fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        win.backgroundColor = .clear
        win.isOpaque = false
        win.hasShadow = false
        win.level = .statusBar + 1
        win.ignoresMouseEvents = true

        self.init(window: win)

        setupOverlay()
        startSpinning()
    }

    private func setupOverlay() {
        let overlay = NSView()
        overlay.wantsLayer = true
        overlay.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.4).cgColor

        indicator = NSProgressIndicator()
        indicator.style = .spinning
        indicator.controlSize = .large
        indicator.isIndeterminate = true
        indicator.translatesAutoresizingMaskIntoConstraints = false

        overlay.addSubview(indicator)
        window?.contentView = overlay

        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: overlay.centerYAnchor)
        ])
    }

    private func startSpinning() {
        indicator.startAnimation(nil)
    }

    private func stopSpinning() {
        indicator.stopAnimation(nil)
    }

    func dismiss(completion: (() -> Void)? = nil) {
        stopSpinning()
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.25
            self.window?.animator().alphaValue = 0
        } completionHandler: {
            self.window?.orderOut(nil)
            self.window?.alphaValue = 1
            completion?()
        }
    }
}
