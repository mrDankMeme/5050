//
//  SettingsInfoSection.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//

import SwiftUI

struct SettingsInfoSection: View {
    let onSupport: () -> Void
    let onTerms: () -> Void
    let onPrivacy: () -> Void

    var body: some View {
        SettingsGroupCard {
            SettingsNavRow(
                asset: "support",
                title: "Support",
                action: onSupport
            )

            Divider().padding(.leading, 52.scale)

            SettingsNavRow(
                asset: "termsOfUse",
                title: "Terms of Use",
                action: onTerms
            )

            Divider().padding(.leading, 52.scale)

            SettingsNavRow(
                asset: "privacyPolicy",
                title: "Privacy Policy",
                action: onPrivacy
            )
        }
    }
}
