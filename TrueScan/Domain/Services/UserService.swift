//  UserService.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//

import Foundation

protocol UserService {
    func fetchMe() async throws -> UserReadDTO
}
