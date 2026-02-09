// Presentation/Lock/PasscodeSetupView.swift
//
//  PasscodeSetupView.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//

import SwiftUI

struct PasscodeSetupView: View {

    let title: String
    let onComplete: (_ code: String) -> Void
    let onCancel: () -> Void

    @State private var first: String = ""
    @State private var confirm: String = ""
    @State private var step: Int = 1
    @State private var errorText: String?

    var body: some View {
        ZStack {
            Tokens.Color.backgroundMain.ignoresSafeArea()

            VStack(spacing: 0) {

                HStack {
                    Button { onCancel() } label: {
                        Image("chevronLeft")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Tokens.Color.textPrimary)
                            .frame(width: 20.scale, height: 20.scale)
                    }
                    .buttonStyle(OpacityTapButtonStyle())

                    Spacer(minLength: 0)
                }
                .padding(.top, 10.scale)
                .padding(.horizontal, Tokens.Spacing.x16)
                Spacer()
                // Titles (чуть выше середины, как на макете)
                VStack(alignment: .center, spacing: 0) {
                    Text(title)
                        .font(Tokens.Font.h2)
                        .foregroundStyle(Tokens.Color.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Text(step == 1 ? "Create a 4-digit passcode" : "Confirm passcode")
                        .font(Tokens.Font.medium16)
                        .foregroundStyle(Tokens.Color.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 10.scale)

                    PasscodeDotsView(count: 4, filled: currentCode.count)
                        .padding(.top, 22.scale)

                    if let err = errorText {
                        Text(err)
                            .font(Tokens.Font.medium16)
                            .foregroundStyle(.red)
                            .padding(.top, 10.scale)
                    }
                }
                .padding(.top, 22.scale)
                .padding(.horizontal, Tokens.Spacing.x16)

                PasscodePadView(
                    onDigit: { d in append(d) },
                    onDelete: { deleteOne() }
                )
                .padding(.top, 42.scale)
                .padding(.bottom, 34.scale)
            }
        }
    }

    private var currentCode: String {
        step == 1 ? first : confirm
    }

    private func append(_ digit: String) {
        errorText = nil

        if step == 1 {
            guard first.count < 4 else { return }
            first.append(contentsOf: digit)
            if first.count == 4 {
                step = 2
            }
        } else {
            guard confirm.count < 4 else { return }
            confirm.append(contentsOf: digit)
            if confirm.count == 4 {
                finishIfPossible()
            }
        }
    }

    private func deleteOne() {
        errorText = nil

        if step == 1 {
            guard first.isEmpty == false else { return }
            first.removeLast()
        } else {
            if confirm.isEmpty == false {
                confirm.removeLast()
            } else {
                step = 1
            }
        }
    }

    private func finishIfPossible() {
        guard first.count == 4, confirm.count == 4 else { return }
        guard first == confirm else {
            errorText = "Passcodes do not match"
            confirm = ""
            return
        }
        onComplete(first)
    }
}

// MARK: - UI pieces

private struct PasscodeDotsView: View {
    let count: Int
    let filled: Int

    var body: some View {
        HStack(spacing: 12.scale) {
            ForEach(0..<count, id: \.self) { idx in
                Circle()
                    // аккуратные серые точки (как в твоём lock-экране)
                    .fill(idx < filled
                          ? Tokens.Color.textSecondary.opacity(0.55)
                          : Tokens.Color.textSecondary.opacity(0.25))
                    .frame(width: 12.scale, height: 12.scale)
                    .transaction { $0.animation = nil }
            }
        }
    }
}
