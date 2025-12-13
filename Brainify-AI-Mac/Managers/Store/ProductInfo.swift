//
//  ProductInfo.swift
//  DownTik
//
//  Created by Macbook Pro on 16/08/2023.
//  
//

import Foundation
import StoreKit
import SwiftyStoreKit

struct ProductInfo: Equatable {
    let id: String
    let displayName: String
    let description: String
    let currencySymbol: String
    let price: CGFloat
    let displayPrice: String
    let period: SubscriptionPeriod?
    let periodCount: Int
    let product: Any

    func purchase() async throws -> Any? {
        try await StoreManager.shared.purchase(product: self)
    }

    var introductoryOffer: OfferInfo? {
        if #available(iOS 15.0, *), let product = product as? Product {
            if let introOffer = product.subscription?.introductoryOffer {
                return .init(
                    type: .from(introOffer.type),
                    price: CGFloat(truncating: NSDecimalNumber(decimal: introOffer.price)),
                    displayPrice: introOffer.displayPrice,
                    period: .from(introOffer.period),
                    periodCount: introOffer.periodCount,
                    paymentMethod: .from(introOffer.paymentMode),
                    offer: introOffer
                )
            }
            return nil
        } else if let product = product as? SKProduct {
            if let introOffer = product.introductoryPrice {
                return .init(
                    type: .from(introOffer.type),
                    price: CGFloat(truncating: introOffer.price),
                    displayPrice: introOffer.localizedPrice ?? "",
                    period: .from(introOffer.subscriptionPeriod),
                    periodCount: introOffer.numberOfPeriods,
                    paymentMethod: .from(introOffer.paymentMode),
                    offer: introOffer
                )
            }
        }

        return nil
    }

    func format(price: Decimal) -> String? {
        if #available(iOS 15.0, *), let prd = product as? Product {
            return prd.priceFormatStyle.format(price)
        } else if let prd = product as? SKProduct {
            let formatter = NumberFormatter()
            formatter.locale = prd.priceLocale
            formatter.numberStyle = .currency
            return formatter.string(from: price as NSNumber)
        }

        return nil
    }
    
    func calculateDiscountPercentage(priceBeforeDiscount originalPrice: Double) -> Double {
        let nominalPrice = originalPrice - price
        let denominator: Double = originalPrice
        return (nominalPrice / denominator) * 100
    }

    static func == (lhs: ProductInfo, rhs: ProductInfo) -> Bool {
        lhs.id == rhs.id
    }
}

extension ProductInfo {
    var isMonthly: Bool { period?.unit == .month }
    var isYearly: Bool { period?.unit == .year }
    var isWeekly: Bool { period?.unit == .week }
    var isLifetime: Bool { period == nil }
    var haveFreeTrial: Bool { introductoryOffer?.paymentMethod == .freeTrial }
    var trialDays: Int {
        if let unit = introductoryOffer?.period?.unit,
		   let value = introductoryOffer?.period?.value {
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
        return 0
    }
}

struct OfferInfo {
    let type: OfferType?
    let price: CGFloat
    let displayPrice: String
    let period: SubscriptionPeriod?
    let periodCount: Int
    let paymentMethod: PaymentMode?
    let offer: Any
}

enum OfferType {
    case introductory
    case promotional

    @available(iOS 15.0, *)
    static func from(_ subOfferType: Product.SubscriptionOffer.OfferType) -> Self? {
        switch subOfferType {
            case .introductory:
                return .introductory
            case .promotional:
                return .promotional
            default:
                return nil
        }
    }

    static func from(_ subOfferType: SKProductDiscount.`Type`) -> Self? {
        switch subOfferType {
            case .introductory:
                return .introductory
            case .subscription:
                return nil
            @unknown default:
                return nil
        }
    }
}

enum PaymentMode {
    case payAsYouGo
    case payUpFront
    case freeTrial

    @available(iOS 15.0, *)
    static func from(_ payMode: Product.SubscriptionOffer.PaymentMode) -> Self? {
        switch payMode {
            case .freeTrial:
                return .freeTrial
            case .payUpFront:
                return .payUpFront
            case .payAsYouGo:
                return .payAsYouGo
            default:
                return nil
        }
    }

    static func from(_ payMode: SKProductDiscount.PaymentMode) -> Self? {
        switch payMode {
            case .payAsYouGo:
                return .payAsYouGo
            case .payUpFront:
                return .payUpFront
            case .freeTrial:
                return .freeTrial
            @unknown default:
                return nil
        }
    }
}

struct SubscriptionPeriod {
    enum Unit {
        case day
        case week
        case month
        case year
    }

    let unit: Unit
    let value: Int

    @available(iOS 15.0, *)
    static func from(_ period: Product.SubscriptionPeriod?) -> Self? {
        guard let period else { return nil }

        let unit: Unit

        switch period.unit {
            case .day:
                unit = .day
            case .week:
                unit = .week
            case .month:
                unit = .month
            case .year:
                unit = .year
            @unknown default:
                return nil
        }

        return .init(unit: unit, value: period.value)
    }

    static func from(_ period: SKProductSubscriptionPeriod?) -> Self? {
        guard let period else { return nil }

        let unit: Unit

        switch period.unit {
            case .day:
                unit = .day
            case .week:
                unit = .week
            case .month:
                unit = .month
            case .year:
                unit = .year
            @unknown default:
                return nil
        }

        return .init(unit: unit, value: period.numberOfUnits)
    }
}
