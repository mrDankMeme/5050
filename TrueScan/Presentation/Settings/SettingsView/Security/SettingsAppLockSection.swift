//
//  SettingsAppLockSection.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//


import SwiftUI

struct SettingsAppLockSection: View {
    let onTap: () -> Void

    var body: some View {
        SettingsGroupCard {
            SettingsNavRow(
                asset: "lock",  
                title: "Face ID & Passcode",
                action: onTap
            )
        }
    }
}
