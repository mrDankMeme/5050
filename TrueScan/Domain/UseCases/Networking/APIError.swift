//
//  APIError.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case http(Int, String?)
    case decoding(Error)
    case transport(Error)
    case noData
    case unauthorized
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .http(let code, let body):
            let trimmed = body?
                .replacingOccurrences(of: "\r", with: "")
                .replacingOccurrences(of: "\n", with: " ")
                .prefix(500) ?? ""
            return "HTTP \(code). \(trimmed)"
        case .decoding(let err):
            return "Decoding error: \(err.localizedDescription)"
        case .transport(let err):
            return "Network error: \(err.localizedDescription)"
        case .noData:
            return "Empty response."
        case .unauthorized:
            return "Unauthorized (401)."
        }
    }
}
