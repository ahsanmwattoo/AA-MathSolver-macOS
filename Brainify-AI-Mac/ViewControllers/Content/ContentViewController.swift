//
//  ContentViewController.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 25/11/2025.
//

import Cocoa

class ContentViewController: BaseViewController {

    static var identifier = "ContentViewController"
    
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var premiumViewBox: NSBox!
    @IBOutlet weak var gradientBorderBox: NSBox!
    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var toggleButton: NSButton!
    @IBOutlet weak var sidebarWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var showSidebarButton: NSButton!
    @IBOutlet weak var hideAbleBox: NSBox!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var subtitleLabel: NSTextField!
    @IBOutlet weak var unlockLabel: NSTextField!
    @IBOutlet weak var limitedAccessLabel: NSTextField!
    @IBOutlet weak var upgradeLabel: NSTextField!
    
    var menuItems: [String] = []
    var menuIcons: [NSImage] = []
    private var isSidebarHidden = false
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gradientColor = NSColor.gradientColor(from: .button, to: .brand, size: gradientBorderBox.bounds.size, angle: 300)
        gradientBorderBox.borderColor = gradientColor
        gradientBorderBox.borderWidth = 3
        
        setUpTab()
        menuItems = ["AI Math","Math Topics","Mathematical Formulas","Math Assistant","Calculator","History","Settings"]
        menuIcons = [.sideBarIcon1, .sideBarIcon2, .sideBarIcon3, .sideBarIcon4, .calculator , .sideBarIcon5, .sideBarIcon6]
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isSelectable = true
        collectionView.allowsMultipleSelection = false
        collectionView.allowsEmptySelection = false
        let nib = NSNib(nibNamed: "SideMenuCollectionViewCell", bundle: nil)
        collectionView.register(nib, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SideMenuCollectionViewCell"))
        collectionView.selectItem(index: 0, section: 0)
        hideAbleBox?.isHidden = App.isPro
    }

    override func didChangeLanguage() {
        super.didChangeLanguage()
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            collectionView.selectItem(index: selectedIndex, section: 0)
            titleLabel.stringValue = "Brainify".localized()
            subtitleLabel.stringValue = "AI Math Solver".localized()
            unlockLabel.stringValue = "Unlock all features of your AI companion.".localized()
            limitedAccessLabel.stringValue = "Get Unlimited Access".localized()
            upgradeLabel.stringValue = "Upgrade to PRO".localized()
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        if App.isPro {
            App.incrementLaunchCount()
            if App.isEvenNumber {
                showReviewAlert()
            }
        } else {
            self.showPremiumScreen()
        }
    }
    
    func selectFirstTab() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
            self?.tabView.selectTabViewItem(at: 0)
            self?.collectionView.selectItem(index: 0, section: 0)
            if let mathVC = self?.tabView.tabViewItems[0].viewController as? AIMathViewController {
                mathVC.removeAllChildViewControllers()
                mathVC.textView.string = ""
                mathVC.textInputBox.updateSendButtonEnabled(false)
                if let presentedVC = mathVC.presentedViewControllers?.first {
                    presentedVC.dismiss(nil)
                }
            }
        }
    }

    @IBAction func toggleSidebar(_ sender: NSButton) {
        isSidebarHidden.toggle()
        
        // Animation
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.35
            context.allowsImplicitAnimation = true
            
            if isSidebarHidden {
                sidebarWidthConstraint.constant = 0
                
            } else {
                sidebarWidthConstraint.constant = 230
            }
        }
        
        showSidebarButton.isHidden = !isSidebarHidden
    }

    func setUpTab(){
        let viewModel = HistoryViewModel()
        let mathVC = AIMathViewController(nibName: AIMathViewController.identifier, bundle: nil)
        let mathTopicsVC = MathTopicsViewController(nibName: MathTopicsViewController.identifier, bundle: nil)
        let mathFormulaVC = MathFormulasViewController(nibName: MathFormulasViewController.identifier, bundle: nil)
        let aiAssistantsVC = AIAssistantsViewController(nibName: AIAssistantsViewController.identifier, bundle: nil)
        let historyVC = HistoryViewController(viewModel: viewModel)
        let settingsVC = SettingsViewController(nibName: SettingsViewController.identifier, bundle: nil)
        let calculatorVC = CalculatorViewController(nibName: CalculatorViewController.identifier, bundle: nil)
        
        let mathTab = NSTabViewItem(viewController: mathVC)
        let mathTopicsTab = NSTabViewItem(viewController: mathTopicsVC)
        let mathFormulaTab = NSTabViewItem(viewController: mathFormulaVC)
        let aiAssistantsTab = NSTabViewItem(viewController: aiAssistantsVC)
        let historyTab = NSTabViewItem(viewController: historyVC)
        let settingsTab = NSTabViewItem(viewController: settingsVC)
        let calculatorTab = NSTabViewItem(viewController: calculatorVC)
        
        
        tabView.addTabViewItem(mathTab)
        tabView.addTabViewItem(mathTopicsTab)
        tabView.addTabViewItem(mathFormulaTab)
        tabView.addTabViewItem(aiAssistantsTab)
        tabView.addTabViewItem(calculatorTab)
        tabView.addTabViewItem(historyTab)
        tabView.addTabViewItem(settingsTab)
        tabView.selectTabViewItem(at: 0)
    }
    @IBAction func premiumButtonTapped(_ sender: Any) {
        showPremiumScreen()
    }
}

extension ContentViewController: NSCollectionViewDataSource, NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let cell = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: SideMenuCollectionViewCell.identifier.rawValue), for: indexPath) as! SideMenuCollectionViewCell
        cell.configure(with: menuItems[indexPath.item].localized(), icon: menuIcons[indexPath.item])
        return cell
    }
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        if let selectedIndexPath = indexPaths.first?.item {
            selectedIndex = selectedIndexPath
            tabView.selectTabViewItem(at: selectedIndexPath)
        }
    }
}

extension ContentViewController: NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 210, height: 40)
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
