//  Domain/Services/SubscriptionPlan.swift
//  CheaterBuster

import Foundation

public enum SubscriptionPlan: Equatable {
    case weekly
    case yearly
}

public protocol SubscriptionService {
    func purchase(plan: SubscriptionPlan) async throws
    func restore() async throws
}
