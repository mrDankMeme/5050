//
//  LocationHistoryItem.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/19/25.
//




import Foundation

public struct LocationHistoryItem: Identifiable, Codable, Equatable {

    public let id: UUID
    public let title: String
    public let thumbnailJPEG: Data?
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        title: String,
        thumbnailJPEG: Data? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.thumbnailJPEG = thumbnailJPEG
        self.createdAt = createdAt
    }
}
