//
//  CheaterAPIImpl.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//



import Foundation

final class CheaterAPIImpl: CheaterAPI {

    // MARK: - Dependencies

    private let cfg: APIConfig
    private let http: HTTPClient
    private let tokens: TokenStorage

    // MARK: - Init

    init(cfg: APIConfig, http: HTTPClient, tokens: TokenStorage) {
        self.cfg = cfg
        self.http = http
        self.tokens = tokens
    }

    // MARK: - Auth helpers

    private func authed(_ req: inout URLRequest) {
        if let token = tokens.accessToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Всегда ожидаем JSON
        if req.value(forHTTPHeaderField: "Accept") == nil {
            req.setValue("application/json", forHTTPHeaderField: "Accept")
        }
    }

    // MARK: - /api/task (messages / images)

    /// POST /api/task
    /// files[] + conversation? + app_bundle*
    func createAnalyzeTask(
        files: [MultipartFormData.FilePart],
        conversation: String?
    ) async throws -> TaskReadDTO {

        let url = cfg.baseURL.appendingPathComponent("/api/task")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        authed(&req)

        let mp = MultipartFormData()

        let body = mp.build(
            fields: [
                "conversation": conversation,
                "app_bundle": cfg.bundleId,
                "webhook_url": nil
            ],
            files: files.map { part in
                
                MultipartFormData.FilePart(
                    name: "files",
                    filename: part.filename,
                    mimeType: part.mimeType,
                    data: part.data
                )
            }
        )

        req.setValue(mp.contentType, forHTTPHeaderField: "Content-Type")
        req.httpBody = body

        return try await http.send(req)
    }

    // MARK: - /api/task/place (single file)

    
    
    func createAnalyzePlaceTask(
        file: MultipartFormData.FilePart,
        conversation: String?
    ) async throws -> TaskReadDTO {

        let url = cfg.baseURL.appendingPathComponent("/api/task/place")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        authed(&req)

        let mp = MultipartFormData()

        let body = mp.build(
            fields: [
                "conversation": conversation,
                "app_bundle": cfg.bundleId,
                "webhook_url": nil
            ],
            files: [
                // строго одно поле "file"
                MultipartFormData.FilePart(
                    name: "file",
                    filename: file.filename,
                    mimeType: file.mimeType,
                    data: file.data
                )
            ]
        )

        req.setValue(mp.contentType, forHTTPHeaderField: "Content-Type")
        req.httpBody = body

        return try await http.send(req)
    }

    // MARK: - /api/task/{task_id}

    /// GET /api/task/{id}
    func getAnalyzeTask(
        id: UUID
    ) async throws -> TaskReadDTO {

        // сервер ожидает lowercased UUID
        let lower = id.uuidString.lowercased()
        let url = cfg.baseURL.appendingPathComponent("/api/task/\(lower)")

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        authed(&req)

        return try await http.send(req)
    }

    // MARK: - Reverse image search

    
    func createReverseSearch(
        image: MultipartFormData.FilePart
    ) async throws -> ReverseSearchCreateResponse {

        let url = cfg.baseURL.appendingPathComponent("/api/search")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        authed(&req)

        let mp = MultipartFormData()

        let body = mp.build(
            fields: [:],
            files: [
                MultipartFormData.FilePart(
                    name: "image",
                    filename: image.filename,
                    mimeType: image.mimeType,
                    data: image.data
                )
            ]
        )

        req.setValue(mp.contentType, forHTTPHeaderField: "Content-Type")
        req.httpBody = body

        return try await http.send(req)
    }

    
    func getReverseSearch(
        id: UUID
    ) async throws -> ReverseSearchGetResponse {

        let lower = id.uuidString.lowercased()
        let url = cfg.baseURL.appendingPathComponent("/api/search/\(lower)")

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        authed(&req)

        return try await http.send(req)
    }
}
