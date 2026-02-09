//
//  CheaterHeader.swift
//  CheaterBuster
//

import SwiftUI

struct CheaterHeader: View {
    let title: String
    let onBack: () -> Void

    var body: some View {
        HStack {
            BackButton(size: 44.scale) { onBack() }
            Spacer()
            Text(title)
                .font(Tokens.Font.bodyMedium18) 
                .foregroundStyle(Tokens.Color.textPrimary)
            Spacer()
            Color.clear.frame(width: 44.scale, height: 44.scale)
        }
        .padding(.horizontal, 16.scale)
        .padding(.bottom, 12.scale)
    }
}
