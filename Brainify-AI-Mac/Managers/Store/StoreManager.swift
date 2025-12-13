//
//  StoreManager.swift
//  DownTik
//
//  Created by Macbook Pro on 07/08/2023.
//  
//

import StoreKit
import Combine
import SwiftyStoreKit

final class StoreManager {
    static let product_ids = Set(
        [
            "com.app.ai.math.solver.weekly",
            "com.app.ai.math.solver.monthly",
            "com.app.ai.math.solver.yearly",
        ]
    )
    static let nonConsumable_ids = Set(["com.app.ai.math.solver.lifetime"])
//    static let product_ids = Set(
//        [
//            "com.app.ai.emoji.generator.weekly",
//            "com.app.ai.emoji.generator.monthly",
//            "com.app.ai.emoji.generator.yearly",
//            "com.app.ai.emoji.generator.lifetime",
//        ]
//    )
//    static let nonConsumable_ids = Set(["com.app.ai.emoji.generator.lifetime"])
    static let shared_secret = AppConstants.sharedSecret
    @Published private(set) var products = [ProductInfo]()

    static let shared = StoreManager()
    var onStatusChange: ((PurchaseInfo?) -> Void)? {
        didSet {
            if #available(iOS 15.0, *) {
                Store2.shared.onStatusChange = onStatusChange
            } else {
                Store.shared.onStatusChange = onStatusChange
            }
        }
    }

    private init() {
        if #available(iOS 15.0, *) {
            _ = Store2.shared
        } else {
            _ = Store.shared
        }
    }
    
    // MARK: - List
    func fetchProducts(completion: ((String?) -> Void)? = nil) {
        Task {
            if #available(iOS 15.0, *) {
                do {
                    let products = try await Store2.shared.requestProducts(for: Self.product_ids)
                    self.products = self.productInfoArray(from: products)
                    completion?(nil)
                } catch {
                    self.products = []
                    completion?("Error Fetching Products.")
                }
            } else {
                let products = await Store.shared.requestProducts(for: Self.product_ids)
                self.products = self.productInfoArray(from: products)
                completion?(nil)
            }
        }
    }

    @available(iOS 15.0, *)
    private func getProducts() -> [Product] {
        self.products.compactMap({ $0.product as? Product })
    }

    private func getSKProducts() -> [SKProduct] {
        self.products.compactMap({ $0.product as? SKProduct })
    }

    // MARK: - Purchase
    func purchase(product: ProductInfo) async throws -> Any? {
        if #available(iOS 15.0, *), let product = product.product as? Product {
            return try await Store2.shared.purchase(product)
        } else if let product = product.product as? SKProduct {
            return try await Store.shared.purchase(product)
        }
        return nil
    }

    // MARK: - Restore
    func restore() async throws {
        if #available(iOS 15.0, *) {
            try await Store2.shared.restore()
        } else {
            try await Store.shared.restore()
        }
    }
}

// MARK: - Helpers
extension StoreManager {
    private func productInfoArray(from products: [SKProduct]) -> [ProductInfo] {
        return products.map({
            .init(
                id: $0.productIdentifier,
                displayName: $0.localizedTitle,
                description: $0.description,
                currencySymbol: $0.priceLocale.currencySymbol ?? "$",
                price: CGFloat(truncating: $0.price),
                displayPrice: $0.localizedPrice ?? "",
                period: .from($0.subscriptionPeriod),
                periodCount: $0.subscriptionPeriod?.numberOfUnits ?? 0,
                product: $0
            )
        })
    }

    @available(iOS 15.0, *)
    private func productInfoArray(from products: [Product]) -> [ProductInfo] {
        return products.map({
            .init(
                id: $0.id,
                displayName: $0.displayName,
                description: $0.description,
                currencySymbol: $0.priceFormatStyle.locale.currencySymbol ?? "$",
                price: CGFloat(truncating: NSDecimalNumber(decimal: $0.price)),
                displayPrice: $0.displayPrice,
                period: .from($0.subscription?.subscriptionPeriod),
                periodCount: $0.subscription?.subscriptionPeriod.value ?? 0,
                product: $0
            )
        })
    }
}
