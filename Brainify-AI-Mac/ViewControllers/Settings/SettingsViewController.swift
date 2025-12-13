//
//  SettingsViewController.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 26/11/2025.
//

import Cocoa

class SettingsViewController: BaseViewController {

    static var identifier = "SettingsViewController"
    
    @IBOutlet weak var gradientBorderBox: NSBox!
    @IBOutlet weak var settingsCollectionView: NSCollectionView!
    @IBOutlet weak var upgardeBox: NSBox!
    @IBOutlet weak var headingLabel: NSTextField!
    @IBOutlet weak var subHeadingLabel: NSTextField!
    @IBOutlet weak var hideAbleBox: NSBox!
    @IBOutlet weak var imageViewPro: NSImageView!
    
    var displayedSections: [SettingsSection] {
        App.isPro
            ? SettingsSection.settingsSections.filter { $0.title != "Account" }
            : SettingsSection.settingsSections
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gradientColor = NSColor.gradientColor(from: .button, to: .brand, size: gradientBorderBox.bounds.size, angle: 300)
        gradientBorderBox.borderColor = gradientColor
        gradientBorderBox.borderWidth = 2
        setupCollectionView()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        let gradientColor = NSColor.gradientColor(from: .button, to: .brand, size: gradientBorderBox.bounds.size, angle: 300)
        gradientBorderBox.borderColor = gradientColor
        gradientBorderBox.borderWidth = 2
        settingsCollectionView.collectionViewLayout?.invalidateLayout()
    }
    
    override func appProStatusDidChange() {
        upgardeBox.isHidden = App.isPro
        headingLabel.stringValue = App.isPro ? "Brainify".localized() : "Unlock Premium Features".localized()
        headingLabel.font = App.isPro ? .systemFont(ofSize: 22, weight: .bold) : .systemFont(ofSize: 16, weight: .bold)
        subHeadingLabel.stringValue = App.isPro ? "AI Math Solver".localized() : "Get unlimited access to Brainify features".localized()
        subHeadingLabel.font = App.isPro ? .systemFont(ofSize: 16, weight: .regular) : .systemFont(ofSize: 10, weight: .regular)
        hideAbleBox.isHidden = App.isPro
        imageViewPro.isHidden = !App.isPro
        settingsCollectionView.reloadData()
    }
        
    override func didChangeLanguage() {
        super.didChangeLanguage()
        DispatchQueue.main.async {
            [weak self] in
            guard let self else { return }
            headingLabel.stringValue = App.isPro ? "Brainify".localized() : "Unlock Premium Features".localized()
            subHeadingLabel.stringValue = App.isPro ? "AI Math Solver".localized() : "Get unlimited access to Brainify features".localized()
        }
    }
    
    func setupCollectionView() {
        settingsCollectionView.delegate = self
        settingsCollectionView.dataSource = self
        settingsCollectionView.hideScrollers()
        settingsCollectionView.register(SettingsCollectionViewCell.self, forItemWithIdentifier: SettingsCollectionViewCell.identifier)
        settingsCollectionView.register(SettingsHeaderCollectionViewCell.self,
                                               forSupplementaryViewOfKind: NSCollectionView.elementKindSectionHeader,
                                               withIdentifier: SettingsHeaderCollectionViewCell.Identifier)
    }
    
    @IBAction func didTapPremium(_ sender: Any) {
        showPremiumScreen()
    }
}

extension SettingsViewController: NSCollectionViewDelegate, NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return displayedSections.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayedSections[section].settings.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let cell = settingsCollectionView.makeItem(withIdentifier: SettingsCollectionViewCell.identifier, for: indexPath) as! SettingsCollectionViewCell
        let sectionSettings = displayedSections[indexPath.section].settings
        let isFirstInSection = indexPath.item == 0
        let isLastInSection = indexPath.item == collectionView.numberOfItems(inSection: indexPath.section) - 1
        cell.delegate = self
        cell.configure(with: sectionSettings[indexPath.item], isFirst: isFirstInSection, isLast: isLastInSection)
        return cell
    }
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        guard let header = collectionView.makeSupplementaryView(ofKind: NSCollectionView.elementKindSectionHeader, withIdentifier: SettingsHeaderCollectionViewCell.Identifier, for: indexPath) as? SettingsHeaderCollectionViewCell else { return NSView() }
        
        header.configure(with: displayedSections[indexPath.section].title.localized())
        return header

    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else { return }
        let sectionIndex = indexPath.section
        let setting = displayedSections[sectionIndex].settings[indexPath.item]
        collectionView.deselectItems(at: indexPaths)
        
        switch setting.action {
        case .languageChange:
            break

        case .showPremium:
            showPremiumScreen()
        case .restorePurchase:
            restorePurchase(view)
        case .shareApp:
            Utility.shareApp(appId: AppConstants.appID, sender: view)
        case .openURL(let url):
            NSWorkspace.shared.open(url)
        case .feedback:
            Utility.support()
        case .appearanceChange:
            break
        }
    }
    
    @objc private func selectLanguage(_ sender: NSPopUpButton) {
        if let language = languages.first(where: { $0.languageName == sender.title }) {
            App.appLanguage = language
        }
    }
}

extension SettingsViewController: NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return NSSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
        return NSSize(width: collectionView.frame.width, height: 50)
    }
}

extension SettingsViewController: SettingsCellDelegate {
    
    func didChangeLanguage(to localizedName: String) {
        if let selectedLanguage = languages.first(where: {
            $0.languageName.getLocalizedString(languageCode: $0.code) == localizedName
        }) {
            App.appLanguage = selectedLanguage
            settingsCollectionView.reloadData()
        }
    }
    
    func didChangeAppearance(to title: String) {
        switch title {
        case "Light":
            App.appearance = .Light
        case "Dark":
            App.appearance = .Dark
        case "System":
            App.appearance = .System
        default: return
        }
    }
}
