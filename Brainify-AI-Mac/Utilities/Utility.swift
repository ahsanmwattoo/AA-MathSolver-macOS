//
//  Utility.swift
//  DownTik
//
//  Created by Macbook Pro on 20/05/2025.
//

import Cocoa

class Utility {
    static func showAlert(title: String, message: String, okTitle: String, window: NSWindow) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: okTitle)
        alert.beginSheetModal(for: window)
    }
    
    class func showOneTextfieldAlert(
        messageTest: String,
        informativeText: String = "",
        window: NSWindow,
        completion: ((String?) -> Void)?
    ) {
        let alert = NSAlert()
        alert.informativeText = informativeText
        alert.messageText = messageTest
        alert.addButton(withTitle: "Confirm".localized())
        alert.addButton(withTitle: "Cancel".localized())
        
        let inputTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        inputTextField.focusRingType = .none
        inputTextField.placeholderString = ("Enter chat name".localized())
        alert.accessoryView = inputTextField
        alert.beginSheetModal(for: window) { modalResponse in
            if modalResponse == .alertFirstButtonReturn {
                completion?(inputTextField.stringValue)
            }
        }
    }
    
    class func showAlertSheet(
        message: String,
        information: String,
        window: NSWindow,
        completion: @escaping (Bool) -> Void
    ) {
        let alert = NSAlert()
        alert.messageText = message
        alert.alertStyle = .warning
        alert.informativeText = information
        alert.addButton(withTitle: "Confirm".localized())
        alert.addButton(withTitle: "Cancel".localized())
        alert.beginSheetModal(for: window) { modalResponse in
            let response = modalResponse == .alertFirstButtonReturn
            completion(response)
        }
    }
    
    class func dialogOKCancel(question: String, yesButtonText yesBtnText:String, noButtonText noBtnText:String ) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.alertStyle = .warning
        alert.addButton(withTitle: yesBtnText)
        alert.addButton(withTitle: noBtnText)
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    class func dialogOKWithCancel(question: String, text: String, yesButtonText:String, noButtonText :String ) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: yesButtonText)
        alert.addButton(withTitle: noButtonText)
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    class func dialogOKCancel(question: String, text: String = "") -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.alertStyle = .informational
        alert.informativeText = text
        alert.addButton(withTitle: "Yes").keyEquivalent = "\r"
        alert.addButton(withTitle: "No").keyEquivalent = "\u{1b}"
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    @discardableResult
    class func dialogOK(question: String, text: String, title: String = "OK") -> NSApplication.ModalResponse {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: title)
        return alert.runModal()
    }
    
    @discardableResult
    class func dialogWithOK(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK".localized())
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    class func getWordFromStr(_ str: String,_ count: Int) -> String {
        return str
    }
    
    class func support() -> Void {
        openEmail(address: AppConstants.supportEmail, subject: "", body: "")
    }
    
    class func openLink(link: String) {
        let url = URL(string: link)!
        NSWorkspace.shared.open(url)
    }
}

extension Utility {
    class func openEmail(address: String, subject: String, body: String) {
        var deviceName = ""
        let deviceStr = Host.current().localizedName
        if let device = deviceStr?.components(separatedBy: "’s ").last {
            deviceName = device
        }
        
        var buildVersion = ""
        let pro = (App.isPro) == true ? "P" : ""
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String , let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            buildVersion = "\(version) (\(build))"
        }
        
        let html = NSString.init(format: "<br> <br> <br> <br><br> %@ <br>%@<br><b>OSX Versoin :</b> %@ <br> <b>Device Type :</b> %@ <br> This information will help us to find your issue.", body, AppConstants.appName , ProcessInfo.processInfo.operatingSystemVersionString, deviceName)
        
        let service = NSSharingService(named: NSSharingService.Name.composeEmail)
        service?.recipients = [address]
        service?.subject = "\(AppConstants.appName) | MAC | \(buildVersion) | \(pro)"
        
        service?.perform(withItems: [String.init(html).convertHtml()])
    }
    
    class func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "macappstore://itunes.apple.com/app/id\(appId)?mt=8&action=write-review") else {
            completion(false)
            return
        }
        completion(NSWorkspace.shared.open(url))
    }
    
    class func shareApp(appId: String, sender: NSView) {
        guard let url = URL(string : "macappstore://itunes.apple.com/app/id\(appId)") else {
            return
        }
        let sharingPicker = NSSharingServicePicker(items: [url])
        sharingPicker.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
    }
}
