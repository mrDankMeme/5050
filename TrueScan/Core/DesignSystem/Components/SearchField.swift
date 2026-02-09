//
//  SearchField.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/27/25.
//

import SwiftUI

public struct SearchField: View {
    @Binding var text: String
    var placeholder: String
    var onCommit: (() -> Void)?
    var onCancel: (() -> Void)?

    @FocusState private var focused: Bool

    public init(
        _ placeholder: String,
        text: Binding<String>,
        onCommit: (() -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.onCommit = onCommit
        self.onCancel = onCancel
    }

    public var body: some View {
        HStack(spacing: Tokens.Spacing.x12) {
            HStack(spacing: Tokens.Spacing.x12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Tokens.Color.textSecondary)

                TextField(placeholder, text: $text)
                    .font(Tokens.Font.body)
                    .foregroundColor(Tokens.Color.textPrimary)
                    .focused($focused)
                    .submitLabel(.search)
                    .onSubmit { onCommit?() }

                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Tokens.Color.textSecondary)
                            .frame(width: 20.scale, height: 20.scale)
                    }
                    .accessibilityLabel("Clear text")
                }
            }
            .padding(.horizontal, Tokens.Spacing.x16)
            .padding(.vertical, 12.scale)
            .background(
                Tokens.Color.surfaceCard,
                in: RoundedRectangle(
                    cornerRadius: Tokens.Radius.pill,
                    style: .continuous
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: Tokens.Radius.pill,
                    style: .continuous
                )
                .stroke(Tokens.Color.borderNeutral, lineWidth: 1.scale)
            )
            .apply(Tokens.Shadow.card)

            if focused {
                Button("Cancel") {
                    text = ""
                    focused = false
                    onCancel?()
                }
                .font(Tokens.Font.body)
                .foregroundColor(Tokens.Color.textSecondary)
                .padding(.trailing, Tokens.Spacing.x8)
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .animation(.easeOut(duration: 0.25.scale), value: focused)
    }
}
