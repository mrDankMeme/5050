//  TokensStore.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//

import Foundation

public protocol TokensStore: AnyObject {
    var tokens: Int { get set }
}
