//
//  FindPlaceBottomCTAView.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/18/25.
//


import SwiftUI

struct FindPlaceBottomView: View {

    let title: String
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            ZStack {
                RoundedRectangle(
                    cornerRadius: Tokens.Radius.medium,
                    style: .continuous
                )
                .fill(Tokens.Color.accent)
                .shadow(
                    color: Color.black,
                    radius: 0,
                    x: 2.scale,
                    y: 2.scale
                )

                HStack(spacing: 8.scale) {
                    Text(title)
                        .font(Tokens.Font.semibold16)
                        .tracking(-0.16)

                    Spacer()

                    Image("nextArrow")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 20.scale, height: 20.scale)
                }
                .foregroundColor(.white)
                .padding(.leading, 20.scale)
                .padding(.trailing, 24.scale)
            }
            .frame(width: 343.scale, height: 51.scale)
        }
        .buttonStyle(OpacityTapButtonStyle())
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.bottom, 24.scale)
    }
}
