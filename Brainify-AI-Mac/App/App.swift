//
//  App.swift
//  SnapDownloader
//
//  Created by MackBook Pro on 10/15/25.
//

import Foundation
import StoreKit

class App {
    private static let defaults: UserDefaults = .standard

    static var isPro: Bool {
        get {  defaults.bool(forKey: "isPremium") }
        set {
            defaults.set(newValue, forKey: "isPremium")
            NotificationCenter.default.post(name: .appProStatusDidChange, object: nil)
        }
    }
    
    static var isNotPro: Bool { !isPro }
    
    // MARK: - Free Usage Limit
    private static var freeCount: Int {
        get { defaults.integer(forKey: "freeCount") }
        set { defaults.set(newValue, forKey: "freeCount") }
    }
    
    static func incrementFreeCount() {
        guard App.isNotPro else { return }
        freeCount += 1
    }
    
    private static var freeAIMathCount: Int {
        get { defaults.integer(forKey: "freeAIMathCount") }
        set { defaults.set(newValue, forKey: "freeAIMathCount") }
    }
    
    static func incrementFreeAIMathCount() {
        guard App.isNotPro else { return }
        freeAIMathCount += 1
    }
    
    private static var freeAICount: Int {
        get { defaults.integer(forKey: "freeAICount") }
        set { defaults.set(newValue, forKey: "freeAICount") }
    }
    
    static func incrementFreeAICount() {
        guard App.isNotPro else { return }
        freeAICount += 1
    }
    
    private static var freeTopicCount: Int {
        get { defaults.integer(forKey: "freeTopicCount") }
        set { defaults.set(newValue, forKey: "freeTopicCount") }
    }
    
    static func incrementFreeTopicCount() {
        guard App.isNotPro else { return }
        freeTopicCount += 1
    }

    // MARK: - Helpers
    static var isFree: Bool {
        return freeCount < 1 || freeAIMathCount < 1 || freeAICount < 1 || freeTopicCount < 1
    }
    
    static var canSendQuery: Bool {
        isFree || isPro
    }
    
    static var appearance: Appearance {
        get { .init(rawValue: defaults.string(forKey: "appearance") ?? Appearance.System.rawValue) ?? .System }
        set {
            defaults.set(newValue.rawValue, forKey: "appearance")
            switch newValue {
            case .System:
                NSApp.appearance = nil
            case .Light:
                NSApp.appearance = NSAppearance(named: .aqua)
            case .Dark:
                NSApp.appearance = NSAppearance(named: .darkAqua)
            }
        }
    }
    
    static var chatLanguage: String {
        get { defaults.string(forKey: "chatLanguage") ?? "English" }
        set { defaults.set(newValue, forKey: "chatLanguage") }
    }
    
    static var isAppReviewed: Bool {
        get { defaults.bool(forKey: "isAppReviewed") }
        set { defaults.setValue(newValue, forKey: "isAppReviewed") }
    }
    
    static func requestReview() {
        SKStoreReviewController.requestReview()
    }
    
    private static var launchCount: Int {
        get {
            defaults.integer(forKey: "launchCount")
        }
        set {
            defaults.set(newValue, forKey: "launchCount")
        }
    }
    
    static func incrementLaunchCount() {
        launchCount += 1
    }
    
    static var isEvenNumber: Bool {
        return (launchCount % 2 == 0)
    }
    
    static var appLanguage: Languages {
        get {
            let language = languages.first(where: { $0.code == defaults.string(forKey: "appLanguage") ?? "en" })
            return language ?? .init(languageName: "English", code: "en")
        }
        set {
            defaults.set(newValue.code, forKey: "appLanguage")
            Localize.setCurrentLanguage(newValue.code)
        }
    }
    
   static var reviewRequested: Bool {
        get { defaults.bool(forKey: "reviewRequested") }
       set { defaults.setValue(newValue, forKey: "reviewRequested") }
    }
}
