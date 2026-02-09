// Data/Services/SubscriptionServiceStub.swift

import Foundation

final class SubscriptionServiceStub: SubscriptionService {

    private let store: PremiumStore

    init(store: PremiumStore) {
        self.store = store
    }

    func purchase(plan: SubscriptionPlan) async throws {
        try await Task.sleep(nanoseconds: 400_000_000)
        store.isPremium = true
    }

    func restore() async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        store.isPremium = true
    }
}
