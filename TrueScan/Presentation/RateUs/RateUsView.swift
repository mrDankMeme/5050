//  RateUsView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//

import SwiftUI
import StoreKit
import UIKit

struct RateUsView: View {
    
    let imageName: String
    
    let onLater: () -> Void
    let onRated: () -> Void
    
    
    @State private var didTrackAppear = false
    
    init(
        imageName: String = "rateus_hand",
        onLater: @escaping () -> Void,
        onRated: @escaping () -> Void
    ) {
        self.imageName = imageName
        self.onLater = onLater
        self.onRated = onRated
    }
    
    var body: some View {
  
        let isSmallStatusBar = DeviceLayout.type == .smallStatusBar
        let isNotch = DeviceLayout.type == .notch
        let isDynamicIsland = DeviceLayout.type == .dynamicIsland
  
        ZStack {
            Tokens.Color.backgroundMain.ignoresSafeArea()
           
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: isSmallStatusBar ? 30.scale : 60.scale)
                Text("Rate us")
                    .font(Tokens.Font.medium18)
                    .foregroundStyle(Tokens.Color.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 24.scale)
              
                Spacer(minLength: 24.scale)
                
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 375.scale, height: 330.scale)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scaleEffect(isSmallStatusBar ? 0.8 : 1.0)
                    .offset(y: isSmallStatusBar ? 0.scale : ( isNotch ? -60.scale : -30.scale))
                    .padding(.bottom,  isSmallStatusBar ? 8.scale : ( isNotch ? 0.scale : 32.scale))
                
                VStack(spacing: 14.scale) {
                    Text("Do you love using\nCheater Booster?")
                        .font(Tokens.Font.title)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Tokens.Color.textPrimary)
                        .padding(.horizontal, 24.scale)
                        
                    
                    Text("Your support helps more women protect their hearts and trust their intuition.")
                        .font(Tokens.Font.regular16)
                        .foregroundStyle(Tokens.Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24.scale)
                        .opacity(0.7)
                        
                }
                .padding(.top,  isSmallStatusBar ? -10.scale : ( isNotch ? -130.scale : -130.scale))
                .padding(.bottom, 24.scale)
                
                Spacer()
                
                VStack(spacing: 6.scale) {
                    PrimaryButton("Rate now") {
                        Analytics.shared.track("rateus_custom_now")
                        requestReviewInCurrentScene()
                        onRated()
                    }
                    .buttonStyle(OpacityTapButtonStyle())
                    
                    Button(action: {
                        Analytics.shared.track("rateus_custom_later")
                        onLater()
                    }) {
                        Text("Rate later")
                            .font(Tokens.Font.bodySemibold16)
                            .foregroundStyle(Tokens.Color.textSecondary.opacity(0.6))
                            .lineLimit(1)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10.scale)
                    }
                    .buttonStyle(OpacityTapButtonStyle())
                }
                .padding(.horizontal, 24.scale)
                .padding(.bottom,isSmallStatusBar ? 16.scale : 32.scale)
            }
        }
        .accessibilityIdentifier("rateus.screen")
        .onAppear {
            guard !didTrackAppear else { return }
            didTrackAppear = true
            Analytics.shared.track("rateus_custom_shown")
        }
    }

    
    // MARK: - iOS 14+: корректный вызов ревью в текущей сцене без @MainActor
    private func requestReviewInCurrentScene() {
        DispatchQueue.main.async {
            guard let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }) else {
                return
            }
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
