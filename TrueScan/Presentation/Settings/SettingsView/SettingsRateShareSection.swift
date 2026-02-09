//
//  SettingsRateShareSection.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//


import SwiftUI

struct SettingsRateShareSection: View {
    let onRate: () -> Void
    let onShare: () -> Void

    var body: some View {
        SettingsGroupCard {
            SettingsNavRow(
                asset: "rateUs",
                title: "Rate Us",
                action: onRate
            )

            Divider().padding(.leading, 52.scale)

            SettingsNavRow(
                asset: "shareWithFriends",
                title: "Share with friends",
                action: onShare
            )
        }
    }
}
