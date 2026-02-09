//
//  FindPlaceResultScreen.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/18/25.
//

import SwiftUI
import UIKit

struct FindPlaceResultScreen: View {

    let image: UIImage?
    let resultText: String

    let onBack: () -> Void
    let onFindOutMore: () -> Void

    let showFindOutMoreButton: Bool

    // ⬅️ ЕДИНСТВЕННОЕ ДОБАВЛЕНИЕ
    @State private var didSignalRateUs: Bool = false

    init(
        image: UIImage?,
        resultText: String,
        onBack: @escaping () -> Void,
        onFindOutMore: @escaping () -> Void,
        showFindOutMoreButton: Bool = true
    ) {
        self.image = image
        self.resultText = resultText
        self.onBack = onBack
        self.onFindOutMore = onFindOutMore
        self.showFindOutMoreButton = showFindOutMoreButton
    }

    var body: some View {
        Group {
            

                VStack(spacing: 0) {

                    header
                        .padding(.top, 0.scale)

                    Spacer(minLength: 0)

                    if let img = image {
                        CheaterImageCard(image: img)
                            .frame(maxWidth: 343.scale)
                            .frame(maxHeight: 460.scale)
                            .padding(.horizontal, 8.scale)
                            .padding(.top, 16.scale)
                            .layoutPriority(1)
                    }

                    Spacer().frame(height: 24.scale)

                    resultCard(text: resultText)
                        .padding(.horizontal, 16.scale)

                    Spacer().frame(height: 24.scale)
                    if showFindOutMoreButton {
                        bottomCTA
                    }
                }
            
        }
        .background(Tokens.Color.backgroundMain.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .edgeSwipeToPop(isEnabled: true) { onBack() }
        .toolbar(showFindOutMoreButton ? .visible : .hidden, for: .tabBar)

        // ⬅️ ЕДИНСТВЕННОЕ ПОВЕДЕНЧЕСКОЕ ДОБАВЛЕНИЕ
        .onAppear {
            requestRateUsIfNeeded()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            BackButton(size: 40.scale) { onBack() }

            Spacer()

            Text("Location identified")
                .font(Tokens.Font.bodyMedium18)
                .foregroundStyle(Tokens.Color.textPrimary)

            Spacer()

            Color.clear.frame(width: 40.scale, height: 40.scale)
        }
        .padding(.horizontal, 16.scale)
    }

    // MARK: - Result Card

    private func resultCard(text: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20.scale, style: .continuous)
                .fill(Tokens.Color.surfaceCard)
                .shadow(
                    color: Tokens.Color.blue,
                    radius: 0,
                    x: 2,
                    y: 2
                )

            HStack(alignment: .top, spacing: 12.scale) {
                Image("home.location")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22.scale, height: 22.scale)
                    .foregroundStyle(Tokens.Color.accent)
                    .padding(.top, 2.scale)

                VStack(alignment: .leading, spacing: 6.scale) {
                    Text("AI Analysis Result")
                        .font(Tokens.Font.bodySemibold16)
                        .foregroundStyle(Tokens.Color.textPrimary)

                    Text(text)
                        .font(Tokens.Font.regular16)
                        .foregroundStyle(Tokens.Color.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16.scale)
            .padding(.vertical, 14.scale)
        }
    }


    // MARK: - Bottom CTA

    private var bottomCTA: some View {
        Button { onFindOutMore() } label: {
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

                Text("Find out more location")
                    .font(Tokens.Font.bodySemibold16)
                    .tracking(-0.16)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
            }
            .frame(height: 56.scale)
        }
        .buttonStyle(OpacityTapButtonStyle())
        .padding(.horizontal, 16.scale)
        .padding(.bottom, 24.scale)
    }


    // MARK: - Rate Us

    private func requestRateUsIfNeeded() {
        guard didSignalRateUs == false else { return }
        didSignalRateUs = true

        // Всегда делегируем решение Scheduler'у
        RateUsScheduler.shared.requestCustom(.findPlaceResults)
    }
}
