//
//  ImageHit.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import Foundation

public struct ImageHit: Identifiable, Hashable {
    public let id: UUID
    public let title: String
    public let source: String
    public let thumbnailURL: URL?
    public let linkURL: URL?

    
    public let sourceIconURL: URL?

    public init(
        id: UUID = UUID(),
        title: String,
        source: String,
        thumbnailURL: URL?,
        linkURL: URL?,
        sourceIconURL: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.source = source
        self.thumbnailURL = thumbnailURL
        self.linkURL = linkURL
        self.sourceIconURL = sourceIconURL
    }
}
