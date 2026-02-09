// Presentation/Feedback/FeedbackPopupModifier.swift
// TrueScan / CheaterBuster

import SwiftUI

struct FeedbackPopupModifier<PopupContent: View>: ViewModifier {

    @Binding var isPresented: Bool
    let onBackgroundTap: (() -> Void)?
    let popup: () -> PopupContent

    @State private var animateIn: Bool = false

    func body(content: Content) -> some View {
        ZStack {
            content

            if isPresented {
                Color.black.opacity(animateIn ? 0.65 : 0.0)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        onBackgroundTap?()
                        dismiss()
                    }
                    .accessibilityIdentifier("feedback.popup.dim")

                popup()
                    .scaleEffect(animateIn ? 1.0 : 0.92)
                    .opacity(animateIn ? 1.0 : 0.0)
                    .animation(.spring(response: 0.32, dampingFraction: 0.86), value: animateIn)
                    .transition(.opacity)
                    .padding(.horizontal, 22.scale)
                    .frame(maxWidth: 520)
            }
        }
        // ✅ КЛЮЧЕВО: если isPresented уже true на первом показе — запускаем animateIn тут
        .onAppear {
            if isPresented {
                animateIn = false
                DispatchQueue.main.async {
                    animateIn = true
                }
            }
        }
        .onChange(of: isPresented) { _, newValue in
            if newValue {
                animateIn = false
                DispatchQueue.main.async {
                    animateIn = true
                }
            } else {
                animateIn = false
            }
        }
    }

    private func dismiss() {
        animateIn = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            isPresented = false
        }
    }
}

extension View {
    func feedbackPopup<PopupContent: View>(
        isPresented: Binding<Bool>,
        onBackgroundTap: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> PopupContent
    ) -> some View {
        modifier(
            FeedbackPopupModifier(
                isPresented: isPresented,
                onBackgroundTap: onBackgroundTap,
                popup: content
            )
        )
    }
}
