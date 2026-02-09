//
//  UserReadDTO.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//

import Foundation

public struct UserReadDTO: Codable {
    public let id: UUID
    public let apphud_id: String
    public let tokens: Int
}

public struct CreateUserDTO: Codable {
    public let apphud_id: String
}

public struct AuthorizeUserDTO: Codable {
    public let user_id: UUID
}

public struct TokenResponseDTO: Codable {
    public let access_token: String
    public let token_type: String
}

