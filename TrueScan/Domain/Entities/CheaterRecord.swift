//
//  CheaterRecord.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import Foundation

public struct CheaterRecord: Identifiable, Hashable, Codable {
    public enum Kind: String, Codable {
        case image
        case file
        case text
    }

    public let id: UUID
    public let date: Date
    public let kind: Kind
    public let riskScore: Int
    public let note: String?
    public let redFlags: [String]
    public let recommendations: [String]
    public let imageJPEG: Data?

    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        kind: Kind,
        riskScore: Int,
        note: String? = nil,
        redFlags: [String],
        recommendations: [String],
        imageJPEG: Data? = nil
    ) {
        self.id = id
        self.date = date
        self.kind = kind
        self.riskScore = riskScore
        self.note = note
        self.redFlags = redFlags
        self.recommendations = recommendations
        self.imageJPEG = imageJPEG
    }

    public static func == (lhs: CheaterRecord, rhs: CheaterRecord) -> Bool { lhs.id == rhs.id }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
