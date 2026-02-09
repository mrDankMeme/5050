// Infrastucture/AppLock/AppLockViewModel.swift
//
//  AppLockViewModel.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//

import Foundation
import LocalAuthentication

@MainActor
final class AppLockViewModel: ObservableObject {

    @Published private(set) var isUnlocked: Bool = true
    @Published private(set) var isAuthenticating: Bool = false
    @Published var lastErrorText: String?

    init() {
        syncPrefs()
    }

    func syncPrefs() {
        if AppLockPrefs.isEnabled() == false || AppLockPrefs.hasPasscode() == false {
            isUnlocked = true
        }
    }

    func lockIfNeeded() {
        guard AppLockPrefs.isEnabled(), AppLockPrefs.hasPasscode() else {
            isUnlocked = true
            return
        }
        isUnlocked = false
    }

    
    func lock() {
        lockIfNeeded()
    }

    func unlockWithPasscode(_ code: String) -> Bool {
        let ok = AppLockPrefs.verifyPasscode(code)
        if ok {
            isUnlocked = true
            lastErrorText = nil
        } else {
            lastErrorText = "Wrong passcode"
        }
        return ok
    }

    func canUseBiometrics() -> Bool {
        let context = LAContext()
        var err: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &err)
    }


    func unlockWithBiometrics() async {
        lastErrorText = nil

        guard AppLockPrefs.lockMode() == .biometrics else {
            return
        }

        guard isAuthenticating == false else {
            return
        }

        isAuthenticating = true
        defer { isAuthenticating = false }

        let context = LAContext()
        context.localizedCancelTitle = "Cancel"

        context.localizedFallbackTitle = ""

        let reason = "Unlock TrueScan"

        var canError: NSError?
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &canError)

        guard canEvaluate else {
            lastErrorText = (canError?.localizedDescription).flatMap { $0.isEmpty ? nil : $0 } ?? "Authentication unavailable"
            isUnlocked = false
            return
        }

        do {
            let ok = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: reason
            )

            if ok {
                isUnlocked = true
                lastErrorText = nil
            } else {
                isUnlocked = false
            }
        } catch let laError as LAError {
            lastErrorText = laError.localizedDescription
            isUnlocked = false
        } catch {
            lastErrorText = error.localizedDescription
            isUnlocked = false
        }
    }
}
