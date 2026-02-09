//
//  ApphudPaywallTracker.swift
//  SDK: Apphud 3.6.x
//

import Foundation
import ApphudSDK
import StoreKit

// MARK: - Трекинг показа кастомного экрана пейволла
enum ApphudPaywallTracker {

    
    static var paywallID: String = "main"

    private static var cachedPaywall: ApphudPaywall?

    static func trackShown() {
        
        if let pw = cachedPaywall {
            Apphud.paywallShown(pw)
            return
        }

        
        DispatchQueue.main.async {
            Apphud.paywallsDidLoadCallback { paywalls, _ in
                guard let pw = paywalls.first(where: { $0.identifier == paywallID }) else {
                    #if DEBUG
                    print("[Apphud] paywall '\(paywallID)' not found")
                    #endif
                    return
                }
                cachedPaywall = pw
                Apphud.paywallShown(pw)
            }
        }
    }
}

// MARK: - Хранилище продуктов выбранного paywall
final class ApphudPaywallsStore {

    static let shared = ApphudPaywallsStore()
    private init() {}

    private(set) var productsApphud: [ApphudProduct] = []

    
    func load(paywallID: String, completion: (() -> Void)? = nil) {
        
        DispatchQueue.main.async { [weak self] in
            Apphud.paywallsDidLoadCallback { paywalls, _ in
                guard let self = self else { return }

                if let pw = paywalls.first(where: { $0.identifier == paywallID }) {
                    self.productsApphud = pw.products
                } else {
                    self.productsApphud = []
                    #if DEBUG
                    print("[Apphud] products not loaded: paywall '\(paywallID)' not found")
                    #endif
                }

                completion?()
            }
        }
    }

    // MARK: - Хелперы для UI

    func currencySymbol(for index: Int) -> String? {
        guard index >= 0, index < productsApphud.count else { return nil }
        return productsApphud[index].skProduct?.priceLocale.currencySymbol
    }

    func priceString(for index: Int) -> String? {
        guard index >= 0, index < productsApphud.count else { return nil }
        return productsApphud[index].skProduct?.price.stringValue
    }

    func periodName(for index: Int) -> String? {
        guard index >= 0,
              index < productsApphud.count,
              let period = productsApphud[index].skProduct?.subscriptionPeriod else { return nil }

        switch period.unit {
        case .day:   return "Daily"
        case .week:  return "Weekly"
        case .month: return "Monthly"
        case .year:  return "Yearly"
        @unknown default: return "Unknown"
        }
    }
}
