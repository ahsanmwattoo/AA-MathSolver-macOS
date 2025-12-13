//
//  Setting.swift
//  EmoTalk
//
//  Created by Macbook Pro on 15/10/2025.
//

import Foundation
import Cocoa

enum SettingAction : Equatable {
    case showPremium
    case restorePurchase
    case shareApp
    case openURL(URL)
    case languageChange
    case feedback
    case appearanceChange
}

struct SettingsSection {
    let title: String
    let settings: [Setting]
    
    static let settingsSections: [SettingsSection] = [
        SettingsSection(title: "Account", settings: Setting.premiumSettings),
        SettingsSection(title: "App", settings: Setting.applicationSettings),
        SettingsSection(title: "About", settings: Setting.aboutSettings)
    ]
}

struct Setting {
    let icon: NSImage
    let title: String
    let action: SettingAction
    
    static let premiumSettings: [Setting] = [
        Setting(icon: .settingIcon1, title: "Upgrade to Pro", action: .showPremium),
        Setting(icon: .settingIcon2, title: "Restore Purchase", action: .restorePurchase)
    ]
    
    static let applicationSettings: [Setting] = [
        Setting(icon: .settingIcon3, title: "Share App", action: .shareApp),
        Setting(icon: .settingIcon4, title: "Rate Us", action: .openURL(AppConstants.rateURL)),
        Setting(icon: .settingIcon5, title: "App Language", action: .languageChange),
        Setting(icon: .settingIcon6, title: "Appearance", action: .appearanceChange)
    ]
    
    static let aboutSettings: [Setting] = [
        Setting(icon: .settingIcon7, title: "Support", action: .feedback),
        Setting(icon: .settingIcon8, title: "Privacy Policy", action: .openURL(AppConstants.privacyURL)),
        Setting(icon: .settingIcon9, title: "Terms of Use", action: .openURL(AppConstants.termsURL)),
    ]
}
