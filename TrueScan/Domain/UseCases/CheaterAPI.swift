//  CheaterAPI.swift
//  TrueScan
//

import Foundation

protocol CheaterAPI {

    func createAnalyzeTask(
        files: [MultipartFormData.FilePart],
        conversation: String?
    ) async throws -> TaskReadDTO
    
    func createAnalyzePlaceTask(
        file: MultipartFormData.FilePart,
        conversation: String?
    ) async throws -> TaskReadDTO


    func getAnalyzeTask(
        id: UUID
    ) async throws -> TaskReadDTO


    func createReverseSearch(
        image: MultipartFormData.FilePart
    ) async throws -> ReverseSearchCreateResponse

    func getReverseSearch(
        id: UUID
    ) async throws -> ReverseSearchGetResponse
}
