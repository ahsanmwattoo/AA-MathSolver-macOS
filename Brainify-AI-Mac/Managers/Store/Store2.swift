//
//  Store2.swift
//  DownTik
//
//  Created by Macbook Pro on 03/08/2023.
//  
//

import Foundation
import StoreKit
import SwiftyStoreKit
import Combine

public enum StoreError: Error {
    case failedVerification
}

struct PurchaseInfo {
    var trial: Bool = false
    var expiry: Date?
}

@available(iOS 15.0, *)
class Store2: NSObject, ObservableObject {
    private var updateListenerTask: Task<Void, Error>?
    private var promotionListenerTask: Task<Void, Error>?

    static let shared = Store2()
    var onStatusChange: ((PurchaseInfo?) -> Void)?

    override private init() {
        super.init()

        updateListenerTask = listenForTransactions()

        SwiftyStoreKit.shouldAddStorePaymentHandler = {(_ payment: SKPayment, _ product: SKProduct) -> Bool in
            return true
        }
        Task {
            await updateCustomerProductStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
        promotionListenerTask?.cancel()
        SwiftyStoreKit.shouldAddStorePaymentHandler = nil
    }

    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updateCustomerProductStatus()
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification")
                }
            }
        }
    }

    func requestProducts(for ids: Set<String>) async throws -> [Product] {
        try await Product.products(for: ids)
    }

    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updateCustomerProductStatus()
            await transaction.finish()
            return transaction
        default:
            return nil
        }
    }

    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    @MainActor
    func updateCustomerProductStatus() async {
        let currentEntitlements = Transaction.currentEntitlements
        var purchaseInfo: PurchaseInfo?

        for await result in currentEntitlements {
            do {
                let payload = try result.payloadValue

                print(payload)

                if payload.productType == .autoRenewable, let expireDate = payload.expirationDate, expireDate > Date() {
                    purchaseInfo = .init(expiry: expireDate)

                    if payload.offerType == .introductory {
                        purchaseInfo?.trial = true
                    }

                    break
                } else if payload.productType == .nonConsumable {
                    purchaseInfo = .init()
                    break
                }
            } catch {
                print(error)
            }
        }

        onStatusChange?(purchaseInfo)
    }

    func restore() async throws {
        try await AppStore.sync()
    }
}
