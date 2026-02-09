//
//  SettingsPremiumSection.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//


import SwiftUI

struct SettingsPremiumSection: View {
    let onGetPremium: () -> Void
    let onRestore: () -> Void

    var body: some View {
        SettingsGroupCard {
            SettingsNavRow(
                asset: "premium",
                title: "Get a premium",
                action: onGetPremium
            )

            Divider().padding(.leading, 52.scale)

            SettingsNavRow(
                asset: "restore",
                title: "Restore purchases",
                action: onRestore
            )
        }
    }
}
