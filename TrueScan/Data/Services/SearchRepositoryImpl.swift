//
//  SearchRepositoryImpl.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//


import Foundation


final class SearchRepositoryImpl: SearchRepository {
    private let api: CheaterAPI

    init(api: CheaterAPI) {
        self.api = api
    }

    func createReverseSearch(image: Data, filename: String, mimeType: String) async throws -> UUID {
        let part = MultipartFormData.FilePart(
            name: "image",
            filename: filename,
            mimeType: mimeType,
            data: image
        )
        let created = try await api.createReverseSearch(image: part) 
        return created.task_id
    }

    func getReverseSearch(taskId: UUID) async throws -> ReverseSearchGetResponse {
        try await api.getReverseSearch(id: taskId)
    }
}
