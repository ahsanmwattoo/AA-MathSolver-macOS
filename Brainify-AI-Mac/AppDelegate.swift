//
//  AppDelegate.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 25/11/2025.
//

import Cocoa
import StoreKit
import Firebase

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: WindowController?
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        FirebaseApp.configure()
        
        let windowController = WindowController(windowNibName: "WindowController")
        self.window = windowController
        App.appearance = App.appearance
        windowController.showWindow(self)
        ReachabilityManager.shared.checkInternet()
        StoreManager.shared.onStatusChange = { purchaseInfo in
            if purchaseInfo != nil {
                if !App.isPro {
                    App.isPro = true
                }
            } else {
                if App.isPro {
                    App.isPro = false
                }
            }
        }
        StoreManager.shared.fetchProducts()
        NotificationCenter.default.post(name: Notification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        SKStoreReviewController.requestReview()
        return true
    }
}
