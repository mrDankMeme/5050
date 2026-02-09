//
//  AuthRepository.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//

import Foundation

public protocol AuthRepository {
    var isAuthorized: Bool { get }
    func ensureAuthorized(apphudId: String) async throws
    func me() async throws -> UserReadDTO
}
