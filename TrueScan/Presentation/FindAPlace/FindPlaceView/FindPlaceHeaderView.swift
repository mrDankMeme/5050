//
//  FindPlaceHeaderView.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/18/25.
//



import SwiftUI

struct FindPlaceHeaderView: View {

    let title: String
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Text(title)
                .font(Tokens.Font.medium18)
                .foregroundStyle(Tokens.Color.textPrimary)

            HStack {
                Button {
                    onClose()
                } label: {
                    Image("backButton")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 24.scale, height: 24.scale)
                }
                .foregroundStyle(Tokens.Color.textPrimary)

                Spacer()
            }
        }
        .padding(.top, 4.scale)
    }
}
