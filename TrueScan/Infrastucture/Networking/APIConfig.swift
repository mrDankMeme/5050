//  APIConfig.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//

import Foundation


struct APIConfig {
    let baseURL: URL
    let bundleId: String

    init(baseURL: URL, bundleId: String = Bundle.main.bundleIdentifier ?? "dev.cheaterbuster") {
        self.baseURL = baseURL
        self.bundleId = bundleId
    }
}
