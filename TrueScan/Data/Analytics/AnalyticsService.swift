//
//  AnalyticsService.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 11/28/25.
//


import Foundation
import AmplitudeUnified

protocol AnalyticsService {
    func track(_ event: String)
}

final class AmplitudeServiceImpl: AnalyticsService {
    private let amplitude: Amplitude

    init() {
        self.amplitude = Amplitude(apiKey: "4f1b77403ce1df4b0eae78f86c9d221e")
    }

    func track(_ event: String) {
        amplitude.track(eventType: event, eventProperties: nil)
    }
}

// MARK: - Global helper

/// Удобный синглтон, чтобы из любого места приложения дергать аналитику
/// одной строкой: `Analytics.shared.track("event_name")`
enum Analytics {
    static let shared: AnalyticsService = AmplitudeServiceImpl()
}
