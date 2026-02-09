//  SubscriptionServiceApphud.swift
//  Реализация под Apphud 3.6.x

import Foundation
import ApphudSDK

@MainActor
final class SubscriptionServiceApphud: SubscriptionService {

    private let weeklyID = "week_6.99_not_trial"
    private let yearlyID = "yearly_49.99_not_trial"

    private let store: PremiumStore
    private let center: NotificationCenter

    init(
        store: PremiumStore,
        center: NotificationCenter = .default
    ) {
        self.store = store
        self.center = center
    }

    func purchase(plan: SubscriptionPlan) async throws {
        let targetID: String = {
            switch plan {
            case .weekly: return weeklyID
            case .yearly: return yearlyID
            }
        }()

        guard let product = ApphudPaywallsStore.shared
            .productsApphud
            .first(where: { $0.productId == targetID }) else {
            throw NSError(
                domain: "Apphud",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Product \(targetID) not loaded"]
            )
        }

        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            Apphud.purchase(product) { result in
                // Гарантируем работу на main-очереди:
                DispatchQueue.main.async {
                    if let error = result.error {
                        cont.resume(throwing: error)
                        return
                    }

                    let isActive =
                        (result.subscription?.isActive() == true) ||
                        (result.nonRenewingPurchase?.isActive() == true) ||
                        Apphud.hasActiveSubscription()

                    if isActive {
                        
                        self.store.isPremium = true
                        
                        self.center.post(
                            name: .cbPremiumSynced,
                            object: nil,
                            userInfo: ["active": true]
                        )

                        cont.resume(returning: ())
                    } else {
                        
                        self.store.isPremium = false
                        self.center.post(
                            name: .cbPremiumSynced,
                            object: nil,
                            userInfo: ["active": false]
                        )

                        cont.resume(throwing: NSError(
                            domain: "Apphud",
                            code: 0,
                            userInfo: [NSLocalizedDescriptionKey: "Purchase not active"]
                        ))
                    }
                }
            }
        }
    }

    func restore() async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            Apphud.restorePurchases { subscriptions, nonRenewingPurchases, error in
                
                DispatchQueue.main.async {
                    if let error = error {
                        cont.resume(throwing: error)
                        return
                    }

                    let isActive =
                        (subscriptions?.first?.isActive() == true) ||
                        (nonRenewingPurchases?.first?.isActive() == true) ||
                        Apphud.hasActiveSubscription()

                    if isActive {
                        self.store.isPremium = true
                        self.center.post(
                            name: .cbPremiumSynced,
                            object: nil,
                            userInfo: ["active": true]
                        )

                        cont.resume(returning: ())
                    } else {
                        self.store.isPremium = false
                        self.center.post(
                            name: .cbPremiumSynced,
                            object: nil,
                            userInfo: ["active": false]
                        )

                        cont.resume(throwing: NSError(
                            domain: "Apphud",
                            code: 0,
                            userInfo: [NSLocalizedDescriptionKey: "No active subscription"]
                        ))
                    }
                }
            }
        }
    }
}
