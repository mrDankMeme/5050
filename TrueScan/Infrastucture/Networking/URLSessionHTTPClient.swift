// Data/Network/URLSessionHTTPClient.swift
// CheaterBuster

import Foundation


final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    
    private static func mask(_ token: String) -> String {
        if token.count <= 12 { return "***\(token.count)***" }
        return "\(token.prefix(6))…\(token.suffix(6))"
    }

    private static func logRequest(_ req: URLRequest) {
        #if DEBUG
        let method = req.httpMethod ?? "GET"
        let url = req.url?.absoluteString ?? "nil"
        print("🛰 CB_HTTP → \(method) \(url)")
        if let headers = req.allHTTPHeaderFields, !headers.isEmpty {
            let pretty = headers.map { k, v in
                k.lowercased() == "authorization"
                ? "\(k): Bearer \(mask(v.replacingOccurrences(of: "Bearer ", with: "")))"
                : "\(k): \(v)"
            }.joined(separator: " | ")
            print("   headers: { \(pretty) }")
        }
        if let ct = req.value(forHTTPHeaderField: "Content-Type") {
            let len = req.httpBody?.count ?? 0
            print("   body: Content-Type=\(ct), bytes=\(len)")
        }
        #endif
    }

    private static func logResponse(_ resp: HTTPURLResponse, data: Data) {
        #if DEBUG
        let code = resp.statusCode
        let url = resp.url?.absoluteString ?? "nil"
        let text = String(data: data, encoding: .utf8) ?? "<\(data.count) bytes>"
        print("✅ CB_HTTP ← \(code) \(url)")
        print("   body: \(text.prefix(2000))")
        #endif
    }

    private static func logError(_ code: Int, data: Data) {
        #if DEBUG
        let text = String(data: data, encoding: .utf8) ?? "<\(data.count) bytes>"
        print("⛔️ CB_HTTP ← \(code) BODY: \(text.prefix(2000))")
        #endif
    }

    func send<T: Decodable>(_ request: URLRequest) async throws -> T {
        var req = request
        if req.value(forHTTPHeaderField: "Accept") == nil {
            req.setValue("application/json", forHTTPHeaderField: "Accept")
        }
        Self.logRequest(req)

        let data: Data
        let resp: URLResponse
        do {
            (data, resp) = try await session.data(for: req)
        } catch {
            #if DEBUG
            print("⛔️ CB_HTTP transport error: \(error.localizedDescription)")
            #endif
            throw APIError.transport(error)
        }

        guard let http = resp as? HTTPURLResponse else { throw APIError.noData }
        guard (200..<300).contains(http.statusCode) else {
            if http.statusCode == 401 {
                Self.logError(http.statusCode, data: data)
                throw APIError.unauthorized
            }
            Self.logError(http.statusCode, data: data)
            let body = String(data: data, encoding: .utf8)
            throw APIError.http(http.statusCode, body)
        }

        Self.logResponse(http, data: data)

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            #if DEBUG
            print("⛔️ CB_HTTP decoding error: \(error)")
            #endif
            throw APIError.decoding(error)
        }
    }

    func sendVoid(_ request: URLRequest) async throws {
        var req = request
        if req.value(forHTTPHeaderField: "Accept") == nil {
            req.setValue("application/json", forHTTPHeaderField: "Accept")
        }
        Self.logRequest(req)

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw APIError.noData }
        guard (200..<300).contains(http.statusCode) else {
            if http.statusCode == 401 {
                Self.logError(http.statusCode, data: data)
                throw APIError.unauthorized
            }
            Self.logError(http.statusCode, data: data)
            let body = String(data: data, encoding: .utf8)
            throw APIError.http(http.statusCode, body)
        }

        Self.logResponse(http, data: data)
        _ = data
    }
}
