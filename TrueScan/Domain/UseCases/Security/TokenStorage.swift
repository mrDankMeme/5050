//
//  TokenStorage.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//

import Foundation

protocol TokenStorage: AnyObject {
    var accessToken: String? { get set }
    var userId: String? { get set }
}
