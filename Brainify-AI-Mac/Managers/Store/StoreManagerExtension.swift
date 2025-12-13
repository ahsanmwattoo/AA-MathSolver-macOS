//
//  StoreManagerExtension.swift
//  DownTik
//
//  Created by Macbook Pro on 21/08/2023.
//

import Foundation

// MARK: - Specific Products
extension StoreManager {
    var weekly: ProductInfo? {
        products.first(where: { $0.id == "com.app.ai.math.solver.weekly" })
    }

    var monthly: ProductInfo? {
        products.first(where: { $0.id == "com.app.ai.math.solver.monthly" })
    }

    var yearly: ProductInfo? {
        products.first(where: { $0.id == "com.app.ai.math.solver.yearly" })
    }
    
    var yearlyOffer: ProductInfo? {
        products.first(where: { $0.id == "com.app.ai.math.solver.yearly" })
    }
//    var weekly: ProductInfo? {
//        products.first(where: { $0.id == "com.app.ai.emoji.generator.weekly" })
//    }
//
//    var monthly: ProductInfo? {
//        products.first(where: { $0.id == "com.app.ai.emoji.generator.monthly" })
//    }
//
//    var yearly: ProductInfo? {
//        products.first(where: { $0.id == "com.app.ai.emoji.generator.yearly" })
//    }
//
//    var lifetime: ProductInfo? {
//        products.first(where: { $0.id == "com.app.ai.emoji.generator.lifetime" })
//    }
//    
//    var yearlyOffer: ProductInfo? {
//        products.first(where: { $0.id == "com.app.ai.emoji.generator.yearly" })
//    }
    func mock() -> [ProductInfo] {
        [
            ProductInfo(id: "", displayName: "Weekly", description: "", currencySymbol: "$", price: 7.99, displayPrice: "$7.99", period: .init(unit: .week, value: 1), periodCount: 0, product: ""),
            ProductInfo(id: "", displayName: "Monthly", description: "", currencySymbol: "$", price: 15.99, displayPrice: "$15.99", period: .init(unit: .week, value: 1), periodCount: 0, product: ""),
            ProductInfo(id: "", displayName: "Yearly", description: "", currencySymbol: "$", price: 59.99, displayPrice: "$59.99", period: .init(unit: .week, value: 1), periodCount: 0, product: ""),
            ProductInfo(id: "", displayName: "Lifetime", description: "", currencySymbol: "$", price: 149.99, displayPrice: "$149.99", period: .init(unit: .week, value: 1), periodCount: 0, product: ""),
            ProductInfo(id: "", displayName: "Yearly Offer", description: "", currencySymbol: "$", price: 59.99, displayPrice: "$39.99", period: .init(unit: .week, value: 1), periodCount: 0, product: ""),
        ]
    }
}

extension OfferInfo {
    var durationString: String? {
        guard let unit = period?.unit,
              let value = period?.value
        else {
            return nil
        }

        func mapToDays(unit: SubscriptionPeriod.Unit, value: Int) -> Int {
            switch unit {
                case .day:
                    return value
                case .week:
                    return value * 7
                case .month:
                    return value * 30
                case .year:
                    return value * 365
            }
        }

        return "\(mapToDays(unit: unit, value: value))-days"
    }
}
