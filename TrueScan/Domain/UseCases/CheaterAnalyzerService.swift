//
//  CheaterAnalyzerService.swift
//  CheaterBuster
//

import Foundation
import Combine

public protocol CheaterAnalyzerService {
    func analyze(text: String) -> AnyPublisher<ConversationAnalysis, Error>
}
