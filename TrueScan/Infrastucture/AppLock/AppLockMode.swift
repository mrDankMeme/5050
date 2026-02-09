//
//  AppLockPrefs.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//

import Foundation

enum AppLockMode: String {
    case none
    case biometrics
    case passcode
}

enum AppLockPrefs {
    private static let modeKey = "ts.applock.mode"
    private static let passcodeKey = "ts.applock.passcode_4" // супер-просто, как ты просил

    // MARK: - Mode

    static func lockMode() -> AppLockMode {
        guard let raw = UserDefaults.standard.string(forKey: modeKey),
              let mode = AppLockMode(rawValue: raw)
        else { return .none }
        return mode
    }

    static func setLockMode(_ mode: AppLockMode) {
        UserDefaults.standard.set(mode.rawValue, forKey: modeKey)
    }

    static func isEnabled() -> Bool {
        lockMode() != .none
    }

    // MARK: - Passcode (very simple)

    static func hasPasscode() -> Bool {
        let s = UserDefaults.standard.string(forKey: passcodeKey) ?? ""
        return s.count == 4
    }

    static func readPasscode() -> String? {
        let s = UserDefaults.standard.string(forKey: passcodeKey) ?? ""
        return s.count == 4 ? s : nil
    }

    static func setPasscode(_ code: String) {
        UserDefaults.standard.set(code, forKey: passcodeKey)
    }

    static func clearPasscode() {
        UserDefaults.standard.removeObject(forKey: passcodeKey)
        // если кода нет — выключаем lock полностью (чтобы не было “ужасных вещей”)
        setLockMode(.none)
    }

    static func verifyPasscode(_ code: String) -> Bool {
        guard let saved = readPasscode() else { return false }
        return saved == code
    }
}
