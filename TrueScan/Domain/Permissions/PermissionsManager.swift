//  PermissionsManager.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//

import Foundation

public protocol PermissionsManager {
    func status(of permission: Permission) async -> PermissionStatus
    func request(_ permission: Permission) async -> PermissionStatus
}

public enum Permission {
    case tracking
    case notifications
    case photoLibrary
    case camera
    case files
}

public enum PermissionStatus: Equatable {
    case authorized
    case denied
    case notDetermined
    case restricted
    case temporarilyUnavailable
    case unsupported
}
