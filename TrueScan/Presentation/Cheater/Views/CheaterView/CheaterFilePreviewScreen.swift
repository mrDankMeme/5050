//
//  CheaterFilePreviewScreen.swift
//  CheaterBuster
//

import SwiftUI
import Swinject

struct CheaterFilePreviewScreen: View {
    let name: String?
    let data: Data?
    let resolver: Resolver
    let onAnalyse: () -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            CheaterHeader(title: "Files analysis", onBack: onBack)

            VStack(spacing: 16.scale) {
                Spacer(minLength: 0)

                ZStackForFileName(name: name ?? "Unknown file")

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 8.scale)

            

            VStack(spacing: 12.scale) {
                Button {
                    onAnalyse()
                } label: {
                    ZStack {
                        RoundedRectangle(
                            cornerRadius: 16.scale,
                            style: .continuous
                        )
                        .fill(Tokens.Color.accent)
                        .shadow(
                            color: Color(hex: "#0E0E0E"),
                            radius: 0,
                            x: 2.scale,
                            y: 2.scale
                        )

                        HStack(spacing: 8.scale) {
                            Text("Check messages")
                                .font(Tokens.Font.bodySemibold16)
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

            }
            .padding(.horizontal, 16.scale)
            .padding(.top, 16.scale)
            .padding(.bottom, 24.scale)
        }
        .background(Tokens.Color.backgroundMain.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .edgeSwipeToPop(isEnabled: true) { onBack() }
    }
}
