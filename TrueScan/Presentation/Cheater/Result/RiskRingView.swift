//
//  Presentation/Cheater/Result/RiskRingView.swift
//  CheaterBuster
//
//

import SwiftUI

struct RiskRingView: View {
    let percent: Int

    var body: some View {
        ZStack {
            
            Circle()
                .stroke(
                    Color.black.opacity(0.08),
                    style: StrokeStyle(lineWidth: 17.scale, lineCap: .round)
                )

            
            Circle()
                .trim(from: 0, to: CGFloat(max(0, min(1, Double(percent) / 100.0))))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#FA2C37"),
                            Color(hex: "#FDC800"),
                            Color(hex: "#FDC800"),
                            Color(hex: "#00C850")
                        ]),
                        center: .center,
                        startAngle: .degrees(210),
                        endAngle: .degrees(570)
                    ),
                    style: StrokeStyle(lineWidth: 17.scale, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            Text("\(percent)%")
                .font(Tokens.Font.titleSemibold32)
                .kerning(-0.04 * 32.scale) // ≈ -4%
                .foregroundColor(Tokens.Color.textPrimary)
        }
    }
}
