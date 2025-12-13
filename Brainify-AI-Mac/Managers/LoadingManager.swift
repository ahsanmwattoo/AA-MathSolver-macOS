//
//  LoadingManager.swift
//  SnapDownloader
//
//  Created by MackBook Pro on 10/14/25.
//
import AppKit

final class LoadingManager {
    static let shared = LoadingManager()
    private var loader: LoadingWindowController?
    private init() {}

    func show(on viewController: NSViewController) {
        guard loader == nil, let parent = viewController.view.window else { return }

        let wc = LoadingWindowController()
        loader = wc

        wc.window?.setFrame(parent.frame, display: true, animate: false)
        parent.addChildWindow(wc.window!, ordered: .above)

        wc.window?.alphaValue = 0
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.2
            wc.window?.animator().alphaValue = 1
        }
    }

    func hide(completion: (() -> Void)? = nil) {
        guard let wc = loader else { completion?(); return }
        wc.dismiss {
            if let p = wc.window?.parent { p.removeChildWindow(wc.window!) }
            wc.window?.close()
            self.loader = nil
            completion?()
        }
    }
}
