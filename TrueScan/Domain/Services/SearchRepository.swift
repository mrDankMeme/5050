//  SearchRepository.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//

import Foundation

protocol SearchRepository {
    func createReverseSearch(image: Data, filename: String, mimeType: String) async throws -> UUID
    func getReverseSearch(taskId: UUID) async throws -> ReverseSearchGetResponse
}
