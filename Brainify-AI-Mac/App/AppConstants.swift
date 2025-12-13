//
//  AppConstants.swift
//  SnapDownloader
//
//  Created by MackBook Pro on 10/15/25.
//

import Foundation

class AppConstants {
    static var key = ""
    static var hash = ""
    static var fashionAPIKey = ""
    
    static var requestCount: Int = 0
    static var selectedLanguage: String = "English"
    
    static var appName = "Brainify AI Math Solver"
    static let supportEmail = "ammaraashrafhelp@gmail.com"
    static let sharedSecret = "aa27413e4b0947deb4aafd206a9d5113"
    static let appID = "6756347682"
    
    static let privacyURL = URL(string: "https://sites.google.com/view/ammaraashrafapps/privacy-policy")!
    static let termsURL = URL(string: "https://sites.google.com/view/ammaraashrafapps/terms-of-use")!
    static let moreAppsURL = URL(string: "https://apps.apple.com/pk/developer/ammara-ashraf/id\(appID)")!
    static let thisAppURL = URL(string: "https://apps.apple.com/us/app/id\(appID)")!
    static let rateURL = URL(string: "https://apps.apple.com/app/id\(appID)?action=write-review")!
}
