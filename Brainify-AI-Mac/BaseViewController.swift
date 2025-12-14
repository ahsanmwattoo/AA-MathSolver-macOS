//
//  ViewController.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 25/11/2025.
//

import Cocoa
import Localization_Swift

class BaseViewController: NSViewController {

    static var Identifier = "BaseViewController"
    
    var isShowingHud = false
    private var lottieOverlayView: LottieOverlay?
    var appearanceObserver: NSKeyValueObservation?
    var isNetConnected: Bool {
        return ReachabilityManager.shared.netConnected
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appProStatusDidChange()
        NotificationCenter.default.addObserver(self,
            selector: #selector(appProStatusDidChange),
            name: .appProStatusDidChange, object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(didChangeLanguage),
            name: Notification.Name(LCLLanguageChangeNotification), object: nil)
        appearanceObserver = NSApp.observe(\.effectiveAppearance, changeHandler: { [weak self] _, _ in
            self?.didChangeAppearance()
        })
    }
    
    func didChangeAppearance() {}
    
    @objc func didChangeLanguage() {
        view.localizeSubviews()
    }
        func removeAllChildViewControllers() {
            for child in children {
                child.view.removeFromSuperview()
                child.removeFromParent()
            }
        }
    // MARK: - Loading
    func showLoading() { LoadingManager.shared.show(on: self) }
    func hideLoading(completion: (() -> Void)? = nil) { LoadingManager.shared.hide(completion: completion) }

    // MARK: - Alerts
    func showSuccess(message: String, completion: (() -> Void)? = nil) {
        showAlert(title: "Success".localized(), message: message, style: .informational, completion: completion)
    }
    func showFailure(message: String, completion: (() -> Void)? = nil) {
        showAlert(title: "Error".localized(), message: message, style: .critical, completion: completion)
    }

    func showConfirmationAlert(
        title: String?,
        message: String?,
        confirmTitle: String = "Confirm".localized(),
        confirmAction: @escaping () -> Void,
        cancelTitle: String = "Cancel".localized()
    ) {
        let alert = NSAlert()
        alert.messageText = title ?? ""
        alert.informativeText = message ?? ""
        alert.alertStyle = .warning  // Yeh visual warning ke liye achha hai
        
        // IMPORTANT: Pehle DELETE button add karo
        let deleteButton = alert.addButton(withTitle: confirmTitle)
        deleteButton.keyEquivalent = "\r"          // Enter/Return key → Delete trigger karega
        deleteButton.hasDestructiveAction = true   // Red color (macOS 11+ par dikhega)
        
        // Phir Cancel button
        alert.addButton(withTitle: cancelTitle)
        
        alert.beginSheetModal(for: view.window!) { response in
            // Pehla button = Delete → .alertFirstButtonReturn
            if response == .alertFirstButtonReturn {
                confirmAction()
            }
        }
    }
    
    private func showAlert(title: String, message: String, style: NSAlert.Style, completion: (() -> Void)?) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = style
        alert.addButton(withTitle: "OK".localized())
        alert.beginSheetModal(for: view.window!) { _ in completion?() }
    }

    @objc func appProStatusDidChange() {}

    func showPremiumScreen() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let premiumVC = PremiumViewController(nibName: PremiumViewController.identifier, bundle: nil)
            presentAsSheet(premiumVC)
        }
    }
    deinit { NotificationCenter.default.removeObserver(self) }
}

extension BaseViewController {
    func configureCollectionView(_ collectionView: NSCollectionView, dataSource: NSCollectionViewDataSource, delegate: NSCollectionViewDelegate) {
        collectionView.dataSource = dataSource
        collectionView.delegate = delegate
        collectionView.hideScrollers()
        
        if let scrollView = collectionView.enclosingScrollView {
            scrollView.hasVerticalScroller = false
            scrollView.hasHorizontalScroller = false
            scrollView.verticalScrollElasticity = .none
            scrollView.horizontalScrollElasticity = .none
        }
    }
    
    func showNoInternetAlert() {
        DispatchQueue.main.async { [weak self] in
            self?.showAlert(title: "No Internet!".localized(), message: "Please connect to stable internet, or contact your ISP.".localized())
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: "OK".localized())
        alert.runModal()
    }
}

extension BaseViewController {
    func restorePurchase(_ sender: NSView) {
        if isNetConnected {
            showLoading()
            Task { [weak self] in
                do {
                    guard let self else { return }
                    try await StoreManager.shared.restore()
                    self.hideLoading()
                } catch {
                    self?.hideLoading()
                    self?.showAlert(title: "Error".localized(), message: "Failed to restore purchase, please try again later.".localized())
                }
            }
        } else {
            showNoInternetAlert()
        }
    }
    
    func purchasePlan(_ sender: NSView, selectedProduct: ProductInfo) {
        if isNetConnected {
            showLoading()
            Task { [weak self] in
                do {
                    guard let self else { return }
                    let result = try await StoreManager.shared.purchase(product: selectedProduct)
                    if let success = result as? Bool, success {
                        self.dismiss(nil)
                    } else {
                        self.hideLoading()
                    }
                } catch {
                    self?.showAlert(title: "Error".localized(), message: "Failed to purchase, Please try again.".localized())
                }
                self?.hideLoading()
            }
        } else {
            showNoInternetAlert()
        }
    }
    
    func showReviewAlert() {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Enjoying the App?".localized()
            alert.informativeText = "If you enjoy Brainify app, would you mind rating us on the App Store?".localized()
            alert.alertStyle = .informational
            
            alert.addButton(withTitle: "Rate Us".localized())
            alert.addButton(withTitle: "Give Feedback".localized())
            
            let response = alert.runModal()
            
            switch response {
            case .alertFirstButtonReturn:
                App.reviewRequested = true
                NSWorkspace.shared.open(AppConstants.rateURL)
            case .alertSecondButtonReturn:
                Utility.support()
            default:
                break
            }
        }
    }
}

class DisableInteraction: NSView {
    var userInteractionEnabled: Bool = true
    override func hitTest(_ point: NSPoint) -> NSView? {
        if userInteractionEnabled {
            return super.hitTest(point)
        }
        return nil
    }
}
