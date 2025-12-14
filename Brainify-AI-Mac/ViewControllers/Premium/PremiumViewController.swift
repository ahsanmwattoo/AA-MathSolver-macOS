//
//  PremiumViewController.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 26/11/2025.
//

import Cocoa
import Combine

struct FeatureSlide {
        let imageName: String
        let title: String
    }

class PremiumViewController: BaseViewController {

    static var identifier = "PremiumViewController"
    
    @IBOutlet weak var headingLabel: NSTextField!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var planInfoLabel: NSTextField!
    @IBOutlet weak var buyPlanButton: NSButton!
    @IBOutlet weak var buyPlanButtonLabel: NSTextField!
    @IBOutlet weak var pageView: NSView!
    @IBOutlet weak var subheadingLabel: NSTextField!
    @IBOutlet weak var noCommitmentLabel: NSTextField!
    @IBOutlet weak var descriptionLabel: NSTextField!
    @IBOutlet weak var termsButton: NSButton!
    @IBOutlet weak var privacyButton: NSButton!
    @IBOutlet weak var continueButton: NSButton!
    @IBOutlet weak var restoreButton: NSButton!
    @IBOutlet weak var sideHeadingLabel: NSTextField!
    @IBOutlet weak var featureLabelOne: NSTextField!
    @IBOutlet weak var featureLabelTwo: NSTextField!
    @IBOutlet weak var featureLabelThree: NSTextField!
    @IBOutlet weak var featureLabelFour: NSTextField!
    
    private var currentPage: Int = 0
    private var selectedProduct: ProductInfo?
    private let storeManager = StoreManager.shared
    private var cancellable = Set<AnyCancellable>()
    
    let defaultIndexPath = IndexPath(item: 1, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.headingLabel.setText(
            ["UNLIMITED".localized()],
            color: .brand,
            font: NSFont.systemFont(ofSize: 54, weight: .bold)
        )
        didChangeLanguage()
        setupCollectionView()
        storeManager.$products
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] _ in
                        guard let self else { return }
                        self.collectionView.reloadData()
                        self.collectionView.selectItems(at: Set([self.defaultIndexPath]), scrollPosition: .centeredHorizontally)
                        self.selectedProduct = self.storeManager.monthly
                        self.buyPlanButtonLabel.stringValue = self.selectedProduct?.haveFreeTrial ?? false ? "Start Free Trial".localized() : "C O N T I N U E".localized()
                        self.planInfoLabel.stringValue = self.selectedProduct?.haveFreeTrial ?? false ? "3 Days Free Trial, then".localized() + " \(self.selectedProduct?.displayPrice ?? "--") " + "per month".localized() : ""
                    }.store(in: &cancellable)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        if isNetConnected {
            StoreManager.shared.fetchProducts()
            collectionView.selectItems(at: [defaultIndexPath], scrollPosition: .centeredHorizontally)
        }
    }
    
    override func didChangeLanguage() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            headingLabel.stringValue = "GET UNLIMITED ACCESS".localized()
            self.headingLabel.setText(
                ["UNLIMITED".localized()],
                color: .brand,
                font: NSFont.systemFont(ofSize: 54, weight: .bold)
            )

            self.subheadingLabel.stringValue = "Upgrade to Pro and solve math like a genius!".localized()
            self.noCommitmentLabel.stringValue = "No Commitment,Cancel Anytime".localized()
            self.descriptionLabel.stringValue = "Your subscription will automatically renew unless auto-renew is turned off at least 24-hours before the end of the current subscription period. Payment will be charged to your iTunes account at confirmation of purchase.".localized()

            self.termsButton.title = "Terms of Use".localized()
            self.privacyButton.title = "Privacy Policy".localized()
            self.continueButton.title = "Continue with Free Plan".localized()
            self.restoreButton.title = "Restore Purchase".localized()

            self.sideHeadingLabel.stringValue = "Why Choose Premium?".localized()
            self.featureLabelOne.stringValue = "Unlimited Snap & Solve Math Problems".localized()
            self.featureLabelTwo.stringValue = "Write Math Easily with a Smart Calculator".localized()
            self.featureLabelThree.stringValue = "Instant Access to All Math Formulas".localized()
            self.featureLabelFour.stringValue = "Ask the Math Assistant Anything".localized()
        }
    }

    
    func setupCollectionView() {
        configureCollectionView(collectionView, dataSource: self, delegate: self)
        collectionView.isSelectable = true
        collectionView.allowsMultipleSelection = false
        collectionView.allowsEmptySelection = false
        collectionView.register(PremiumCollectionViewCell.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("PremiumCollectionViewCell"))
    }

    @IBAction func didTapClose(_ sender: Any) {
        dismiss(self)
    }
    @IBAction func limitedVersionTapped(_ sender: Any) {
        dismiss(nil)
    }
    
    @IBAction func buyPlanButtonTapped(_ sender: Any) {
        guard let selectedProduct else { return }
        purchasePlan(view, selectedProduct: selectedProduct)
    }
    
    @IBAction func termsButtonTapped(_ sender: Any) {
        NSWorkspace.shared.open(AppConstants.termsURL)
    }
    
    @IBAction func privacyPolicyButtonTapped(_ sender: Any) {
        NSWorkspace.shared.open(AppConstants.privacyURL)
    }
    
    @IBAction func didTapRestore(_ sender: Any) {
        restorePurchase(view)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension PremiumViewController : NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {

            guard let index = indexPaths.first?.item else { return }
            if index == 0 {
                selectedProduct = storeManager.weekly
            } else if index == 1 {
                selectedProduct = storeManager.monthly
            } else if index == 2 {
                selectedProduct = storeManager.yearly
            }
            
            buyPlanButtonLabel.stringValue = selectedProduct?.haveFreeTrial ?? false ? "Start Free Trial".localized() : "C O N T I N U E".localized()
            planInfoLabel.stringValue = selectedProduct?.haveFreeTrial ?? false ? "3 Days Free Trial, then".localized() + " \(selectedProduct?.displayPrice ?? "--") " + "per month".localized() : ""
    }
}

extension PremiumViewController : NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
            let cell = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "PremiumCollectionViewCell"), for: indexPath) as! PremiumCollectionViewCell
            let index = indexPath.item
            if index == 0 {
                cell.configWeekly(storeManager.weekly)
            } else if index == 1 {
                cell.configureMonthly(storeManager.monthly)
            } else if index == 2 {
                cell.configureAnnual(storeManager.yearly)
            }
            
            return cell
    }
}

extension PremiumViewController : NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return NSSize(width: (collectionView.frame.width - 22) / 3, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 22
    }
}

