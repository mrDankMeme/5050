//
//  HistoryKind.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import Foundation
import UIKit

public enum HistoryKind: String, Codable {
    case name
    case face
}

public struct HistoryRecord: Identifiable, Codable {
    public let id: UUID
    public let createdAt: Date
    public let kind: HistoryKind

    public let query: String?
    public let imageJPEG: Data?
    public let titlePreview: String?
    public let sourcePreview: String?

    
    public let sourceIconURL: String?
    public let sourceLinkURL: String?

    public init(
        id: UUID = UUID(),
        createdAt: Date = .init(),
        kind: HistoryKind,
        query: String? = nil,
        imageJPEG: Data? = nil,
        titlePreview: String? = nil,
        sourcePreview: String? = nil,
        sourceIconURL: String? = nil,
        sourceLinkURL: String? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.kind = kind
        self.query = query
        self.imageJPEG = imageJPEG
        self.titlePreview = titlePreview
        self.sourcePreview = sourcePreview
        self.sourceIconURL = sourceIconURL
        self.sourceLinkURL = sourceLinkURL
    }
}
