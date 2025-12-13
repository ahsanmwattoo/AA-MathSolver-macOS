//
//  OfferViewController.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 26/11/2025.
//

import Cocoa

class OfferViewController: BaseViewController {

    static var identifier = "OfferViewController"
    @IBOutlet weak var offerPercentageLabel: NSTextField!
    @IBOutlet weak var hoursLabel: NSTextField!
    @IBOutlet weak var minutesLabel: NSTextField!
    @IBOutlet weak var secondsLabel: NSTextField!
    @IBOutlet weak var priceLabel: NSTextField!
    @IBOutlet weak var pricePerYearLabel: NSTextField!
    @IBOutlet weak var limitedOfferBoxWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var limitedTimeOfferLabel: NSTextField!
    
    private var selectedProduct: ProductInfo?
    private let storeManager = StoreManager.shared
    private var timer: Timer?
    private var offerEndTime: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startListeningToOfferTimer()
        updateTimerDisplay()
        fetchOfferProductAndUpdateUI()
        updateLimitedOfferBoxWidth()
        
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        timer?.invalidate()
        timer = nil
    }
    
    override func didChangeLanguage() {
        DispatchQueue.main.async {
            [weak self] in
            guard let self else { return }
            updateUIWithOfferProduct()
            limitedTimeOfferLabel.stringValue = "Limited Time Offer".localized()
        }
    }
    
    private func startListeningToOfferTimer() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(offerTimerUpdated),
            name: OfferTimerManager.didUpdateTimeNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(offerTimerExpired),
            name: OfferTimerManager.didExpireNotification,
            object: nil
        )
    }

    @objc private func offerTimerUpdated() {
        updateTimerDisplay()
    }

    @objc private func offerTimerExpired() {
        hoursLabel.stringValue = "00"
        minutesLabel.stringValue = "00"
        secondsLabel.stringValue = "00"
    }

    private func updateTimerDisplay() {
        let remaining = OfferTimerManager.shared.remainingSeconds
        
        let hours = remaining / 3600
        let minutes = (remaining % 3600) / 60
        let seconds = remaining % 60
        
        hoursLabel.stringValue = String(format: "%02d", hours)
        minutesLabel.stringValue = String(format: "%02d", minutes)
        secondsLabel.stringValue = String(format: "%02d", seconds)
        
        if remaining <= 0 {
            offerTimerExpired()
        }
    }
        
    private func fetchOfferProductAndUpdateUI() {
        storeManager.fetchProducts { [weak self] error in
            guard let self else { return }
            
            DispatchQueue.main.async {
                if error != nil {
                    self.showMockOffer()
                } else {
                    self.updateUIWithOfferProduct()
                }
            }
        }
    }
        private func updateUIWithOfferProduct() {
            guard let yearlyProduct = storeManager.yearlyOffer ?? storeManager.yearly else {
                showMockOffer()
                return
            }
            
            selectedProduct = yearlyProduct
            // Assume yearlyProduct.displayPrice is something like "$79.99"
            let yearlyPriceString = yearlyProduct.displayPrice

            // 1. Remove currency symbol and any formatting
            let cleanPriceString = yearlyPriceString.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: ",", with: "")

            // 2. Convert to Double
            if let yearlyPrice = Double(cleanPriceString) {
                // 3. Divide by 12 to get monthly price
                let monthlyPrice = yearlyPrice / 12.0
                
                // 4. Format it as string with 2 decimal places
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                formatter.currencySymbol = "$"
                formatter.maximumFractionDigits = 2
                formatter.minimumFractionDigits = 2
                
                let monthlyPriceString = formatter.string(from: NSNumber(value: monthlyPrice)) ?? "$0.00"
                
                let originalPrice = "$49.99"
                let yearlyPrice = yearlyProduct.displayPrice
                // Update main price
                priceLabel.stringValue = "Only".localized() + " \(monthlyPriceString) " + "per month".localized() + originalPrice
                priceLabel.setText([" \(monthlyPriceString)"], color: .brand, font: NSFont.systemFont(ofSize: 28, weight: .bold))
                
                let attributedString = NSMutableAttributedString(string: "Only".localized() + " \(monthlyPriceString) " + "per month".localized() + " \(originalPrice)".localized())
                let range = (attributedString.string as NSString).range(of: originalPrice)
                attributedString.addAttribute(.strikethroughStyle, value: 2, range: range)
                attributedString.addAttribute(.strikethroughColor, value: NSColor.gray, range: range)
                attributedString.addAttribute(.foregroundColor, value: NSColor.gray, range: range)
                priceLabel.attributedStringValue = attributedString
                
                pricePerYearLabel.stringValue = "billed $39/year".localized().replacingOccurrences(of: "$39", with: yearlyPrice)
                
                let discount = yearlyProduct.calculateDiscountPercentage(priceBeforeDiscount: yearlyProduct.price * 2.4)
                offerPercentageLabel.stringValue = "\(Int(discount))%" + " Off".localized()
            }
        }
    
    private func showMockOffer() {
            // Fallback when no internet or test mode
        priceLabel.setText(["Only $5.99 per month $79.99".localized()], color: .brand, font: NSFont.systemFont(ofSize: 28, weight: .bold))
        pricePerYearLabel.stringValue = "billed $39/year".localized()
        }
    
    private func updateLimitedOfferBoxWidth() {
            limitedTimeOfferLabel.stringValue = "Limited Time Offer".localized()
            let textWidth = limitedTimeOfferLabel.bestWidth(for: limitedTimeOfferLabel.stringValue, height: 40)
            let paddingAndStar: CGFloat = 60 // star + padding
            limitedOfferBoxWidthConstraint.constant = textWidth + paddingAndStar
        }
    
    @IBAction func didTapClose(_ sender: NSButton) {
        dismiss(nil)
    }
    @IBAction func didTapTerms(_ sender: NSButton) {
        NSWorkspace.shared.open(AppConstants.termsURL)
    }
    
    @IBAction func didTapPrivacy(_ sender: NSButton) {
        NSWorkspace.shared.open(AppConstants.privacyURL)
    }
    
    @IBAction func didTapLimitedVersion(_ sender: NSButton) {
        dismiss(nil)
    }
}

