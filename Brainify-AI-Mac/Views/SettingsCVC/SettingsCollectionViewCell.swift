//
//  SettingsCollectionViewCell.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 29/11/2025.
//

import Cocoa

protocol SettingsCellDelegate: AnyObject {
    func didChangeLanguage(to localizedName: String)
    func didChangeAppearance(to title: String)
}

class SettingsCollectionViewCell: NSCollectionViewItem {

    static var identifier = NSUserInterfaceItemIdentifier("SettingsCollectionViewCell")
    @IBOutlet weak var settingLabel: NSTextField!
    @IBOutlet weak var imageIcon: NSImageView!
    @IBOutlet weak var premiumLabel: NSTextField!
    @IBOutlet weak var imageRightSide: NSImageView!
    @IBOutlet weak var popUpButton: CustomSettingsPopUpButton!
    @IBOutlet weak var popUpBox: NSBox!
    
    let bottomBorder = NSBox()
    weak var delegate: SettingsCellDelegate?
    static var appearanceSelectedTitle: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBottomBorder(color: NSColor.stroke, height: 0.8, gap: 0)
        popUpButton.target = self
        popUpButton.action = #selector(popUpChanged(_:))
    }
    
    @objc private func popUpChanged(_ sender: NSPopUpButton) {
        guard let selectedTitle = sender.selectedItem?.title else { return }
        let settingTitle = settingLabel.stringValue
        
        if settingTitle.contains("App Language".localized()) {
            delegate?.didChangeLanguage(to: selectedTitle)
        } else if settingTitle.contains("Appearance".localized()) {
            SettingsCollectionViewCell.appearanceSelectedTitle = selectedTitle
            delegate?.didChangeAppearance(to: selectedTitle)
        }
    }
    
    func addBottomBorder(color: NSColor, height: CGFloat, gap: CGFloat) {
        bottomBorder.boxType = .separator
        bottomBorder.fillColor = color
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomBorder)
        
        NSLayoutConstraint.activate([
            bottomBorder.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -gap),
            bottomBorder.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            bottomBorder.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            bottomBorder.heightAnchor.constraint(equalToConstant: height)
        ])
    }
    
    func configure(with setting: Setting, isFirst: Bool = false, isLast: Bool = false) {
        settingLabel.stringValue = setting.title.localized()
        imageIcon.image = setting.icon
        let isPremium = setting.action == .showPremium
        premiumLabel.isHidden = !isPremium
        premiumLabel.stringValue = "Free Plan".localized()
        let isDropdown = setting.action == .languageChange || setting.action == .appearanceChange
        popUpButton.isHidden = !isDropdown
        popUpBox.isHidden = !isDropdown
        
        imageRightSide.isHidden = isPremium || isDropdown
        if isDropdown {
            let menu = NSMenu()
            
            if setting.action == .languageChange {
                        for language in languages {
                            let localizedName = language.languageName.getLocalizedString(languageCode: language.code)
                            let item = NSMenuItem(title: localizedName, action: nil, keyEquivalent: "")
                            item.representedObject = language
                            
                            if language.code == App.appLanguage.code {
                                item.state = .on
                            }
                            menu.addItem(item)
                        }
                        
                        let currentName = App.appLanguage.languageName.getLocalizedString(languageCode: App.appLanguage.code)
                        popUpButton.menu = menu
                        popUpButton.selectItem(withTitle: currentName)
                    }

            if setting.action == .appearanceChange {
                let menu = NSMenu()
                
                let options = Appearance.allCases
                
                for option in options {
                    let item = NSMenuItem(title: option.rawValue.localized(), action: nil, keyEquivalent: "")
                    
                    if option == App.appearance {
                        item.state = .on
                    }
                    menu.addItem(item)
                }
                popUpButton.menu = menu
            }
        }
        
        if !isLast {
            bottomBorder.isHidden = false
        }
        
        if isFirst {
            view.wantsLayer = true
            view.cRadius = 20
            view.layer?.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if isLast {
            bottomBorder.isHidden = true
            view.wantsLayer = true
            view.cRadius = 20
            view.layer?.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            view.cRadius = 0
        }
        
    }
}


