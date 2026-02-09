//  SubscriptionServiceImpl.swift
//  CheaterBuster

import Foundation

final class SubscriptionServiceImpl: SubscriptionService {
    private let defaults: UserDefaults
    private let key = "cb.subscribed.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    
    var isSubscribed: Bool {
        get { defaults.bool(forKey: key) }
        set { defaults.set(newValue, forKey: key) }
    }

    
    @discardableResult
    func refreshStatus() async throws -> Bool {
        isSubscribed
    }

    // MARK: - SubscriptionService

    func purchase(plan: SubscriptionPlan) async throws {
        
        isSubscribed = true
    }

    func restore() async throws {
        
        _ = isSubscribed
    }
}
