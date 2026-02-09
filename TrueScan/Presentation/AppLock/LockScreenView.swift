// Presentation/Lock/LockScreenView.swift
//
//  LockScreenView.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//

import SwiftUI
import UIKit

struct LockScreenView: View {

    @EnvironmentObject private var appLock: AppLockViewModel

    @State private var input: String = ""
    @State private var didSkipBiometrics = false

    // ✅ Wiggle trigger (анимируемый)
    @State private var shakeTrigger: CGFloat = 0

    private var isBiometricsMode: Bool { AppLockPrefs.lockMode() == .biometrics }

    var body: some View {
        ZStack {
            Tokens.Color.backgroundMain.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                Image("lockLogo80")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80.scale, height: 80.scale)
                    .padding(.bottom, 20.scale)
                    .padding(.top, 2.scale)
                    .shadow(
                        color: Color.black,
                        radius: 0,
                        x: 2.scale,
                        y: 2.scale
                    )

                Text("Welcome")
                    .font(Tokens.Font.h2)
                    .foregroundStyle(Tokens.Color.textPrimary)

                Text("Unlock to continue")
                    .font(Tokens.Font.bodyMedium16)
                    .foregroundStyle(Tokens.Color.textSecondary)
                    .padding(.top, 10.scale)

                PasscodeDotsView(count: 4, filled: input.count)
                    .padding(.top, 20.scale + 18.scale)
                    .modifier(
                        ShakeEffect(
                            animatableData: shakeTrigger,
                            amplitude: 10.scale,
                            shakesPerTrigger: 6
                        )
                    )
                    .padding(.bottom, 6.scale)

                LockKeypadView(
                    isFaceIDEnabled: (isBiometricsMode && didSkipBiometrics == false),
                    onDigit: { d in append(d) },
                    onSkip: {
                       // didSkipBiometrics = true
                        UINotificationFeedbackGenerator().notificationOccurred(.warning)
                        withAnimation(.easeInOut(duration: 0.42)) {
                            shakeTrigger += 1
                        }
                    },
                    onFaceID: {
                        guard isBiometricsMode, didSkipBiometrics == false else { return }
                        Task { await appLock.unlockWithBiometrics() }
                    }
                )
                .padding(.top, 20.scale + 18.scale)

                // Spacer(minLength: 0)
            }
            .padding(.bottom, 28.scale)
        }
        .onAppear {
            didSkipBiometrics = false

            if isBiometricsMode {
                Task { await appLock.unlockWithBiometrics() }
            }
        }
    }

    // MARK: - Input

    private func append(_ digit: String) {
        guard input.count < 4 else { return }
        input.append(contentsOf: digit)

        if input.count == 4 {
            let ok = appLock.unlockWithPasscode(input)
            if ok == false {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                withAnimation(.easeInOut(duration: 0.42)) {
                    shakeTrigger += 1
                }

                input = ""
            } else {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }
    }
}

// MARK: - Dots (ALL GREY)

private struct PasscodeDotsView: View {
    let count: Int
    let filled: Int

    var body: some View {
        HStack(spacing: 12.scale) {
            ForEach(0..<count, id: \.self) { idx in
                Circle()
                    .fill(idx < filled ? Tokens.Color.textSecondary.opacity(0.55) : Tokens.Color.textSecondary.opacity(0.25))
                    .frame(width: 12.scale, height: 12.scale)
                    .transaction { $0.animation = nil }
            }
        }
    }
}

// MARK: - Keypad (compact)

private struct LockKeypadView: View {
    let isFaceIDEnabled: Bool
    let onDigit: (_ digit: String) -> Void
    let onSkip: () -> Void
    let onFaceID: () -> Void

    private let digits: [String] = ["1","2","3","4","5","6","7","8","9"]

    private let colSpacing: CGFloat = 34
    private let rowSpacing: CGFloat = 18
    private let digitFontSize: CGFloat = 34

    var body: some View {
        VStack(spacing: rowSpacing.scale) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: colSpacing.scale) {
                    ForEach(0..<3, id: \.self) { col in
                        let idx = row * 3 + col
                        digitButton(digits[idx])
                    }
                }
            }

            HStack(spacing: colSpacing.scale - 20.scale) {
                Button(action: onSkip) {
                    Text("Skip")
                        .font(Tokens.Font.bodyMedium16)
                        .foregroundStyle(Tokens.Color.textSecondary)
                        .frame(width: 64.scale, height: 44.scale, alignment: .leading)
                }
                .buttonStyle(.plain)

                digitButton("0")

                Button(action: {
                    guard isFaceIDEnabled else { return }
                    onFaceID()
                }) {
                    Image(systemName: "faceid")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26.scale, height: 26.scale)
                        .foregroundStyle(
                            isFaceIDEnabled
                            ? Tokens.Color.textSecondary
                            : Tokens.Color.textSecondary.opacity(0.25)
                        )
                        .frame(width: 64.scale, height: 44.scale, alignment: .trailing)
                }
                .buttonStyle(.plain)
                .disabled(isFaceIDEnabled == false)
            }
            .padding(.top, 2.scale)
        }
    }

    private func digitButton(_ d: String) -> some View {
        Button(action: { onDigit(d) }) {
            Text(d)
                .font(.system(size: digitFontSize.scale, weight: .regular))
                .foregroundStyle(Tokens.Color.textPrimary)
                .frame(width: 64.scale, height: 44.scale, alignment: .center)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Wiggle (всегда возвращается в 0)

private struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat
    var amplitude: CGFloat = 10
    var shakesPerTrigger: CGFloat = 6

    func effectValue(size: CGSize) -> ProjectionTransform {
        let progress = animatableData - floor(animatableData)

        let translation = amplitude * sin(progress * 2 * .pi * shakesPerTrigger)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}
