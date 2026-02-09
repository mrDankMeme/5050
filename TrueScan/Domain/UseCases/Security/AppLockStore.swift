//
//  AppLockStore.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//
 
import Foundation

public protocol AppLockStore: AnyObject {

    /// Пользователь включил/выключил FaceID/TouchID-лок.
    var isBiometricsEnabled: Bool { get set }

    /// Пользователь включил/выключил лок по passcode.
    var isPasscodeEnabled: Bool { get set }

    /// Хэш passcode (например, 4 цифры). nil = passcode не задан.
    var passcodeHash: String? { get set }
}
