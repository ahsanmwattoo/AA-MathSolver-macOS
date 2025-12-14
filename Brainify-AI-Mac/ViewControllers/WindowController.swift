//
//  WindowController.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 25/11/2025.
//

import Cocoa

class WindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        removeToolbarButtons()
        let splashVC = SplashViewController(nibName: SplashViewController.identifier, bundle: nil)
        self.window?.contentViewController = splashVC
        self.window?.minSize = NSSize(width: 1200, height: 750)
        self.window?.setContentSize(NSSize(width: 1200, height: 750))
        self.window?.center()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self, let window = self.window else { return }
            let contentVC = ContentViewController(nibName: ContentViewController.identifier, bundle: nil)
            window.contentViewController = contentVC
            
            window.minSize = NSSize(width: 1200, height: 750)
            window.setContentSize(NSSize(width: 1200, height: 750))
            window.center()
            addToolbarButtons()
        }
    }
    
    func removeToolbarButtons() {
        window?.styleMask.remove(.closable)
        window?.styleMask.remove(.miniaturizable)
        window?.styleMask.remove(.resizable)
    }
    
    func addToolbarButtons() {
        window?.styleMask.insert(.closable)
        window?.styleMask.insert(.miniaturizable)
        window?.styleMask.insert(.resizable)
    }
}
