//
//  CheaterAnalyzerServiceImpl.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import Foundation
import Combine

final class CheaterAnalyzerServiceImpl: CheaterAnalyzerService {
    func analyze(text: String) -> AnyPublisher<ConversationAnalysis, Error> {
        let score = min(100, max(0, text.count % 100))
        let mock = ConversationAnalysis(
            riskScore: score,
            redFlags: [
                "Asks to move off-platform",
                "Urgency for payment"
            ],
            recomendations: [
                "Ask for a short video call",
                "Don’t prepay"
            ]
        )

        return Just(mock)
            .delay(for: .milliseconds(400), scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
