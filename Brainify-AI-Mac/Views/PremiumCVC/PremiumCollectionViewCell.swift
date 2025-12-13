//
//  PremiumCollectionViewCell.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 27/11/2025.
//

import Cocoa
import Combine

class PremiumCollectionViewCell: NSCollectionViewItem {
    
    static var Identifier = "PremiumCollectionViewCell"

    @IBOutlet weak var infoBoxView: NSBox!
    @IBOutlet weak var infoLabel: NSTextField!
    @IBOutlet weak var durationLabel: NSTextField!
    @IBOutlet weak var priceLabel: NSTextField!
    @IBOutlet weak var pricePerDayOrWeekLabel: NSTextField!
    @IBOutlet weak var backgroundBox: NSBox!
    @IBOutlet weak var infoBoxWidth: NSLayoutConstraint!
    
    private var selectedProduct: ProductInfo?
    private let storeManager = StoreManager.shared
    private var cancellable = Set<AnyCancellable>()
    let defaultIndexPath = IndexPath(item: 1, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        infoBoxView.fillColor = .infoBox
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundBox.fillColor = isSelected ? .brand : .sideBar
            durationLabel.textColor = isSelected ? .white : .labelColor
            priceLabel.textColor = isSelected ? .white : .labelColor
            pricePerDayOrWeekLabel.textColor = isSelected ? .white : .secondaryText
        }
    }
    
    func configWeekly(_ product: ProductInfo?) {
        guard let product else { return }
        
        durationLabel.stringValue = "Weekly".localized()
        priceLabel.stringValue = product.displayPrice
        infoLabel.stringValue = "Basic".localized()
        infoBoxWidth.constant = infoLabel.bestWidth(for: "Basic".localized(), height: 32) + 32
        infoBoxView.cornerRadius = 17
        pricePerDayOrWeekLabel.stringValue = String(format: "$%.2f", product.price / 7) + " / day".localized()
        configurePlanInfo(product, setPlanInfoLabel: false)
    }
    
    func configureMonthly(_ product: ProductInfo?) {
        guard let product else { return }
        
        durationLabel.stringValue = "Monthly".localized()
        priceLabel.stringValue = product.displayPrice
        infoLabel.stringValue = "3 Days Free Trial".localized()
        infoBoxWidth.constant = infoLabel.bestWidth(for: "3 Days Free Trial".localized(), height: 32) + 32
        infoBoxView.cornerRadius = 17
        pricePerDayOrWeekLabel.stringValue = String(format: "$%.2f", product.price / 4) + " / Week".localized()
        configurePlanInfo(product)
    }
    
    func configureAnnual(_ product: ProductInfo?) {
        guard let product else { return }
        durationLabel.stringValue = "Yearly".localized()
        priceLabel.stringValue = product.displayPrice
        pricePerDayOrWeekLabel.stringValue = String(format: "$%.2f", product.price / 52) + " / Week".localized()
        configurePlanInfo(product)
    }
    
    private func configurePlanInfo(_ product: ProductInfo, setPlanInfoLabel: Bool = true) {
        if product.haveFreeTrial {
            infoBoxView.fillColor = .trial
            infoLabel.stringValue = "3 Days Free Trial".localized()
            infoLabel.textColor = .black
        } else {
            infoBoxView.fillColor = .infoBox
            
            if setPlanInfoLabel {
                if let weeklyPrice = StoreManager.shared.weekly?.price {
                    let discount = product.calculateDiscountPercentage(priceBeforeDiscount: weeklyPrice * 52)
                    infoLabel.textColor = .labelColor
                    infoLabel.stringValue = "Save".localized() + " \(Int(discount))%"
                    infoBoxWidth.constant = infoLabel.bestWidth(for: "Save".localized() + " \(Int(discount))%", height: 32) + 32
                    infoBoxView.cornerRadius = 17
                } else {
                    infoBoxView.isHidden = true
                }
            }
        }
    }
}
