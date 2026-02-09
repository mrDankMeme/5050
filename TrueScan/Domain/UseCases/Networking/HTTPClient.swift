//
//  HTTPClient.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//

import Foundation

public protocol HTTPClient {
    func send<T: Decodable>(_ request: URLRequest) async throws -> T
    func sendVoid(_ request: URLRequest) async throws
}
