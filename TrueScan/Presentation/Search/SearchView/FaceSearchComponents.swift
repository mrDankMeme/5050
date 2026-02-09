//
//  HeaderBar.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 11/2/25.
//

import SwiftUI

struct HeaderBar: View {
    let title: String
    let onBack: () -> Void
    var body: some View {
        HStack {
            BackButton(size: 44.scale) { onBack() }
            Spacer()
            Text(title)
                .font(Tokens.Font.bodyMedium18)
                .foregroundStyle(Color(hex: "#141414"))
            Spacer()
            Color.clear.frame(width: 44.scale, height: 44.scale)
        }
        .padding(.horizontal, 16.scale)
        .padding(.top, 16.scale)
    }
}

struct ControlButton: View {
    let asset: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 8.scale, style: .continuous)
                    .fill(Tokens.Color.blue)
                    .frame(width: 48.scale, height: 48.scale)
                    .offset(x: 2.scale, y: 2.scale)
               
                RoundedRectangle(cornerRadius: 8.scale, style: .continuous)
                    .fill(Color(hex: "#DDE4EF"))
                    .frame(width: 48.scale, height: 48.scale)
                    

                Image(asset)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 20.scale, height: 20.scale)
                    .foregroundStyle(Color(hex: "#141414"))
            }
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 22.scale, style: .continuous))
    }
}

struct NextButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Tokens.Color.accent)
                    .frame(width: 48.scale, height: 48.scale)
                    .shadow(color: Tokens.Color.shadowBlack7, radius: 12.scale)
                    .shadow(color: Tokens.Color.shadowBlack7.opacity(0.6), radius: 4.scale)

                Image("nextArrow")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 20.scale, height: 20.scale)
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
    }
}
