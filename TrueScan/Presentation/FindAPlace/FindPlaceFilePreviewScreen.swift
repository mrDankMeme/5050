// Presentation/FindPlace/FindPlaceFilePreviewScreen.swift

import SwiftUI

struct FindPlaceFilePreviewScreen: View {
    let name: String?
    let data: Data?

    let onAnalyse: (_ name: String?, _ data: Data?) -> Void
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

            // Нижняя кнопка "Find a Place"
            VStack(spacing: 12.scale) {
                Button {
                    onAnalyse(name, data)
                } label: {
                    HStack(spacing: 8.scale) {
                        Text("Find a Place")
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
                    .frame(width: 343.scale, height: 51.scale, alignment: .center)
                    .background(Tokens.Color.accent)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: Tokens.Radius.pill,
                            style: .continuous
                        )
                    )
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
