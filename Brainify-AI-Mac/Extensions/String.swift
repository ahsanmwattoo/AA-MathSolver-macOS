//
//  NSString.swift
//  DownTik
//
//  Created by Ahsan Murtaza on 24/06/2024.
//

import Foundation

extension String {
    var isNotEmpty: Bool {
        return !isEmpty
    }
    
    var isBase64Image: Bool {
        starts(with: "data:image/jpeg;base64,")
    }
    
    var isImageURL: Bool {
        starts(with: "https://")
    }
    
    var isBlank: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

extension String {
    func matches(for regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = NSString(string: self)
            let results = regex.matches(in: self, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range) }
        } catch let error {
            print("Invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}


extension String{
    func localized() -> String {
        return localized(using: nil, in: .main)
    }
    
    func getLocalizedString(languageCode: String) -> String {
        if let languageBundle = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
          let bundle = Bundle(path: languageBundle) {
          return NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
        } else {
          return self
        }
      }
    
    func localized(using tableName: String?, in bundle: Bundle?) -> String {
        let LCLBaseBundle = "Base"
        let bundle: Bundle = bundle ?? .main
        if let path = bundle.path(forResource: Localize.currentLanguage(), ofType: "lproj"),
            let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: self, value: nil, table: tableName)
        }
        else if let path = bundle.path(forResource: LCLBaseBundle, ofType: "lproj"),
            let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: self, value: nil, table: tableName)
        }
        return self
    }
}

let LCLCurrentLanguageKey = "LCLCurrentLanguageKey"
public let LCLLanguageChangeNotification = "LCLLanguageChangeNotification"
let LCLDefaultLanguage = "en"

class Localize: NSObject {
    
    open class func availableLanguages(_ excludeBase: Bool = false) -> [String] {
        var availableLanguages = Bundle.main.localizations
        if let indexOfBase = availableLanguages.firstIndex(of: "Base") , excludeBase == true {
            availableLanguages.remove(at: indexOfBase)
        }
        return availableLanguages
    }
    
    open class func currentLanguage() -> String {
        if let currentLanguage = UserDefaults.standard.object(forKey: LCLCurrentLanguageKey) as? String {
            return currentLanguage
        }
        return defaultLanguage()
    }
    
    open class func setCurrentLanguage(_ language: String) {
        let selectedLanguage = availableLanguages().contains(language) ? language : defaultLanguage()
        if (selectedLanguage != currentLanguage()){
            UserDefaults.standard.set(selectedLanguage, forKey: LCLCurrentLanguageKey)
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: Notification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
        }
    }
    
    open class func defaultLanguage() -> String {
        var defaultLanguage: String = String()
        guard let preferredLanguage = Bundle.main.preferredLocalizations.first else {
            return LCLDefaultLanguage
        }
        let availableLanguages: [String] = self.availableLanguages()
        if (availableLanguages.contains(preferredLanguage)) {
            defaultLanguage = preferredLanguage
        }
        else {
            defaultLanguage = LCLDefaultLanguage
        }
        return defaultLanguage
    }
    
    open class func resetCurrentLanguageToDefault() {
        setCurrentLanguage(self.defaultLanguage())
    }
    
    open class func displayNameForLanguage(_ language: String) -> String {
        let locale : NSLocale = NSLocale(localeIdentifier: currentLanguage())
        if let displayName = locale.displayName(forKey: NSLocale.Key.identifier, value: language) {
            return displayName
        }
        return String()
    }

}

extension String {
    func convertHtml() -> NSAttributedString{
        guard let data = data(using: .utf8) else { return NSAttributedString()   }
        do {
            
            return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html, NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
}


extension String {
    func prettyText() -> String {
        self
            .replacingOccurrences(of: "\\frac", with: "/")
            .replacingOccurrences(of: "{", with: "")
            .replacingOccurrences(of: "}", with: "")
            .replacingOccurrences(of: "\\sqrt", with: "√")
            .replacingOccurrences(of: "^", with: "↑")
            .replacingOccurrences(of: "\\pi", with: "π")
            .replacingOccurrences(of: "\\infty", with: "∞")
            .replacingOccurrences(of: "\\int", with: "∫")
            .replacingOccurrences(of: "\\sum", with: "Σ")
            .replacingOccurrences(of: "\\ln", with: "ln")
            .replacingOccurrences(of: "\\log_b", with: "log(b)")
            .replacingOccurrences(of: "\\log", with: "log")
            .replacingOccurrences(of: "\\cos", with: "cos")
            .replacingOccurrences(of: "\\sin", with: "sin")
            .replacingOccurrences(of: "\\tan", with: "tan")
            .replacingOccurrences(of: "\\lim", with: "lim")
            .replacingOccurrences(of: "\\cdot", with: "⋅")
            .replacingOccurrences(of: "\\left", with: "")
            .replacingOccurrences(of: "\\right", with: "")
            .replacingOccurrences(of: "\\\\", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
