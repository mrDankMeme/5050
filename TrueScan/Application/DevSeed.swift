//
//  DevSeed.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//


import Foundation
import Swinject

enum DevSeed {
    static func run(_ resolver: Resolver) {
        #if DEBUG
//        guard let store = resolver.resolve(CheaterStore.self) else { return }
//        if store.load().isEmpty {
//            store.add(.init(
//                kind: .image,
//                riskScore: 80,
//                note: "WhatsApp screenshot",
//                redFlags: [],
//                recommendations: []
//            ))
//            store.add(.init(
//                kind: .file,
//                riskScore: 92,
//                note: "PDF contract",
//                redFlags: [],
//                recommendations: []
//            ))
//        }
        #endif
    }
}
