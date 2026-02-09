//
//  PaywallViewModel.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//

import Foundation
import Combine
import StoreKit



final class PaywallViewModel: ObservableObject {

    // MARK: - Public Output
    @Published var selected: SubscriptionPlan = .yearly
    @Published private(set) var isProcessing: Bool = false
    @Published var errorText: String?
    @Published private(set) var didFinish: Bool = false
    @Published var featureIndex: Int = 0

    // MARK: - Deps
    private let subscription: SubscriptionService

    // MARK: - Internals
    private var runningTask: Task<Void, Never>?

    // MARK: - Init
    init(subscription: SubscriptionService) {
        self.subscription = subscription

        
        ApphudPaywallsStore.shared.load(paywallID: ApphudPaywallTracker.paywallID)
    }

    deinit {
        runningTask?.cancel()
    }

    // MARK: - Intents
    func buy() {
        guard !isProcessing else { return }
        runExclusively { [selected, weak self] in
            try await self?.subscription.purchase(plan: selected)
        }
    }

    func restore() {
        guard !isProcessing else { return }
        runExclusively { [weak self] in
            try await self?.subscription.restore()
        }
    }

    func select(plan: SubscriptionPlan) {
        selected = plan
    }

    func resetCompletion() {
        didFinish = false
    }

    // MARK: - Private Helpers
    private func runExclusively(_ operation: @escaping () async throws -> Void) {
        runningTask?.cancel()

        runningTask = Task { [weak self] in
            guard let self else { return }

            
            DispatchQueue.main.async {
                self.isProcessing = true
                self.errorText = nil
            }

            do {
                try await operation()

                if !Task.isCancelled {
                    DispatchQueue.main.async {
                        self.didFinish = true
                    }
                }
            } catch is CancellationError {
                
            } catch {
                let message = self.localized(error)
                DispatchQueue.main.async {
                    self.errorText = message
                }
            }

            DispatchQueue.main.async {
                self.isProcessing = false
            }
        }
    }

    private func localized(_ error: Error) -> String {
        let nsError = error as NSError
        if nsError.domain == SKErrorDomain,
           nsError.code == SKError.paymentCancelled.rawValue {
            return "Purchase was cancelled."
        }
        return nsError.localizedDescription.isEmpty
            ? "Something went wrong. Please try again."
            : nsError.localizedDescription
    }
}
