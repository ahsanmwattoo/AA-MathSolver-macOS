//
//  Store.swift
//  DownTik
//
//  Created by Macbook Pro on 17/08/2023.
//  
//

import StoreKit
import SwiftyStoreKit

class Store: NSObject {
    static let shared = Store()
    var onStatusChange: ((PurchaseInfo?) -> Void)?

    override private init() {
        super.init()

        completeTransaction()
        SwiftyStoreKit.shouldAddStorePaymentHandler = {(_ payment: SKPayment, _ product: SKProduct) -> Bool in
            return true
        }

        Task {
            try? await updateCustomerProductStatus()
        }
    }

    deinit {
        SwiftyStoreKit.shouldAddStorePaymentHandler = nil
    }

    private func completeTransaction() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                    case .purchased, .restored:
                        if purchase.needsFinishTransaction {
                            SwiftyStoreKit.finishTransaction(purchase.transaction)
                        }
                    case .failed, .purchasing, .deferred:
                        break
                    @unknown default:
                        break
                }
            }
        }
    }

    func requestProducts(for ids: Set<String>) async -> [SKProduct] {
        await withCheckedContinuation { continuation in
            SwiftyStoreKit.retrieveProductsInfo(ids) { result in
                continuation.resume(returning: Array(result.retrievedProducts))
            }
        }
    }

    func purchase(_ product: SKProduct) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            if SwiftyStoreKit.canMakePayments {
                SwiftyStoreKit.purchaseProduct(product) { result in
                    switch result {
                        case .success(purchase: let purchaseDetails):
                            Task {
                                try? await self.updateCustomerProductStatus(with: purchaseDetails)
                                continuation.resume(returning: true)
                            }
                        case .error(let error):
                            continuation.resume(throwing: error)
                    case .deferred(purchase: let purchase):
                        print("Deffered Purchase")
                        print(purchase)
                    }
                }
            } else {
                continuation.resume(returning: false)
            }
        }
    }

    @MainActor
    func updateCustomerProductStatus(with purchaseDetails: PurchaseDetails? = nil) async throws {
        let verificationResult = try await verifySubscriptions()
        var purchaseInfo: PurchaseInfo?

        switch verificationResult {
            case .purchased(_, let items):
                if let latestReciept = items.first {
                    if let expiryDate = latestReciept.subscriptionExpirationDate {
                        purchaseInfo = .init(trial: latestReciept.isTrialPeriod, expiry: expiryDate)
                    } else {
                        purchaseInfo = .init()
                    }
                }
            case .expired, .notPurchased:
                break
        }

        onStatusChange?(purchaseInfo)
    }

    private func verifySubscriptions() async throws -> VerifySubscriptionResult {
        let validator = AppleReceiptValidator(service: .production, sharedSecret: StoreManager.shared_secret)
        return try await withCheckedThrowingContinuation({ continuation in
            SwiftyStoreKit.verifyReceipt(using: validator) { result in
                switch result {
                    case .success(let receipt):
                        var isPurchased = false

                        for id in StoreManager.nonConsumable_ids {
                            let purchaseResult = SwiftyStoreKit.verifyPurchase(productId: id, inReceipt: receipt)
                            if case .purchased = purchaseResult {
                                isPurchased = true
                                break
                            }
                        }

                        if isPurchased {
                            continuation.resume(returning: .purchased(expiryDate: Date(), items: []))
                            return
                        }

                        let subscriptionsResult = SwiftyStoreKit.verifySubscriptions(
                            ofType: .autoRenewable,
                            productIds: StoreManager.product_ids,
                            inReceipt: receipt,
                            validUntil: Date()
                        )

                        continuation.resume(returning: subscriptionsResult)
                    case .error(let error):
                        continuation.resume(throwing: error)
                }
            }
        })
    }

    func restore() async throws {
        try await updateCustomerProductStatus()
    }
}
