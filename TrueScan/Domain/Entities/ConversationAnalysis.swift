//
//  ConversationAnalysis.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import Foundation

public struct ConversationAnalysis: Equatable {
    public let riskScore: Int
    public let redFlags: [String]
    public let recomendations: [String]
    
    public init(
        riskScore: Int,
        redFlags: [String],
        recomendations: [String]
    ) {
        self.riskScore = riskScore
        self.redFlags = redFlags
        self.recomendations = recomendations
    }
}
