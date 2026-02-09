//
//  SplashLoadingView.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//

import SwiftUI

struct SplashLoadingView: View {

    let onFinished: () -> Void

    @State private var activeDot: Int = 0
    @State private var didStart: Bool = false

    private let dotCount: Int = 3

    var body: some View {
        ZStack {
            Tokens.Color.surfaceCard
                .ignoresSafeArea()

            VStack {
                Spacer()

                Image("loadingIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 130.scale, height: 130.scale)

                Spacer()

                ThreeDotsLoaderBlue()
                    .padding(.bottom, 40.scale)
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        guard !didStart else { return }
        didStart = true

        Task {
        
            let steps = 8
            for _ in 0..<steps {
                try? await Task.sleep(nanoseconds: 360_000_000)
                await MainActor.run {
                    activeDot = (activeDot + 1) % dotCount
                }
            }

            await MainActor.run {
                onFinished()
            }
        }
    }
}

