// Presentation/Cheater/Result/CheaterResultView.swift
// CheaterBuster

import SwiftUI

private struct ResultModel: Equatable {
    let riskScore: Int
    let redFlags: [String]
    let recommendations: [String]
}

struct CheaterResultView: View {
    private let model: ResultModel
    private let onBack: () -> Void
    private let onSelectMessage: () -> Void
    private let analysisTitle: String
    private let showSelectMessageButton: Bool

    @State private var didSignalRateUs = false

    init(
        result: TaskResult,
        onBack: @escaping () -> Void = {},
        onSelectMessage: @escaping () -> Void = {},
        analysisTitle: String = "Image analysis",
        showSelectMessageButton: Bool = true
    ) {
        self.model = .init(
            riskScore: result.risk_score,
            redFlags: result.red_flags,
            recommendations: result.recommendations
        )
        self.onBack = onBack
        self.onSelectMessage = onSelectMessage
        self.analysisTitle = analysisTitle
        self.showSelectMessageButton = showSelectMessageButton
    }

    init(
        record: CheaterRecord,
        onBack: @escaping () -> Void = {},
        onSelectMessage: @escaping () -> Void = {},
        analysisTitle: String = "Image analysis",
        showSelectMessageButton: Bool = true
    ) {
        self.model = .init(
            riskScore: record.riskScore,
            redFlags: record.redFlags,
            recommendations: record.recommendations
        )
        self.onBack = onBack
        self.onSelectMessage = onSelectMessage
        self.analysisTitle = analysisTitle
        self.showSelectMessageButton = showSelectMessageButton
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    summaryBlock
                        .padding(.horizontal, 16.scale)
                        .padding(.top, 8.scale)

                    if !model.redFlags.isEmpty {
                        Text("Red flags")
                            .font(Tokens.Font.bodyMedium18)
                            .foregroundStyle(Tokens.Color.textPrimary)
                            .padding(.horizontal, 16.scale)
                            .padding(.top, 32.scale)

                        VStack(spacing: 8.scale) {
                            ForEach(model.redFlags, id: \.self) { txt in
                                RedFlagCard(
                                    title: "Suspicious language detected",
                                    subtitle: "Phrase: \(txt)"
                                )
                            }
                        }
                        .padding(.horizontal, 16.scale)
                        .padding(.top, 16.scale)
                        .padding(.bottom, 32.scale)
                    }

                    if model.redFlags.isEmpty && !model.recommendations.isEmpty {
                        Spacer().frame(height: 24.scale)
                    }

                    if !model.recommendations.isEmpty {
                        Text("Recommendations")
                            .font(Tokens.Font.bodyMedium18)
                            .foregroundStyle(Tokens.Color.textPrimary)
                            .padding(.horizontal, 16.scale)

                        VStack(spacing: 8.scale) {
                            ForEach(model.recommendations, id: \.self) { rec in
                                RecommendationCard(
                                    title: "Save evidence",
                                    subtitle: rec
                                )
                            }
                        }
                        .padding(.horizontal, 16.scale)
                        .padding(.top, 16.scale)
                    }

                    if showSelectMessageButton {
                        PrimaryButton("Check another message") {
                            onSelectMessage()
                        }
                        .padding(.horizontal, 16.scale)
                        .padding(.vertical, 24.scale)
                    } else {
                        Spacer().frame(height: 20.scale)
                    }
                }
            }
            .background(Tokens.Color.backgroundMain.ignoresSafeArea())
        }
        .navigationBarHidden(true)
        .onAppear {
            guard !didSignalRateUs else { return }
            didSignalRateUs = true
            RateUsScheduler.shared.requestCustom(.cheaterResults)
        }
    }

    private var header: some View {
        HStack(spacing: 0) {
            BackButton(size: 44.scale, action: onBack)
            Spacer()
            Text(analysisTitle)
                .font(Tokens.Font.bodyMedium18)
                .foregroundStyle(Tokens.Color.textPrimary)
            Spacer()
            Color.clear.frame(width: 44.scale, height: 44.scale)
        }
        .padding(.horizontal, 16.scale)
        .padding(.top, 10.scale)
        .padding(.bottom, 8.scale)
        .background(Tokens.Color.backgroundMain)
    }

    private var summaryBlock: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 8.scale) {
                Text("Risk analysis complete")
                    .font(Tokens.Font.title)
                    .foregroundStyle(Tokens.Color.textPrimary)

                Image("tickSquare")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 24.scale, height: 24.scale)
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            Text(detectedSubtitle(for: model.riskScore))
                .font(Tokens.Font.bodyMedium)
                .foregroundStyle(Tokens.Color.textSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 8.scale)

            RiskRingView(percent: model.riskScore)
                .frame(width: 120.scale, height: 120.scale)
                .frame(maxWidth: .infinity)
                .padding(.top, 24.scale)

            RiskLevelPillView(score: model.riskScore)
                .padding(.top, 16.scale)

            HStack(spacing: 24.scale) {
                legendDot(.green, text: "Low")
                legendDot(.yellow, text: "Medium")
                legendDot(.red, text: "High")
            }
            .padding(.top, 16.scale)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func legendDot(_ color: Color, text: String) -> some View {
        HStack(spacing: 8.scale) {
            Circle().fill(color).frame(width: 20.scale, height: 20.scale)
            Text(text)
                .font(Tokens.Font.bodyMedium)
                .foregroundStyle(Tokens.Color.textSecondary)
        }
    }

    private func riskLevelLabel(for score: Int) -> String {
        switch score {
        case 0..<34:  return "Low risk level"
        case 34..<67: return "Medium risk level"
        default:      return "High risk level"
        }
    }

    private func detectedSubtitle(for score: Int) -> String {
        switch score {
        case 0..<34:  return "Low risk detected in this message"
        case 34..<67: return "Medium risk detected in this message"
        default:      return "High risk detected in this message"
        }
    }
}

private struct RiskLevelPillView: View {
    let score: Int

    private var title: String {
        switch score {
        case 0..<34:  return "Low risk level"
        case 34..<67: return "Medium risk level"
        default:      return "High risk level"
        }
    }

    private var palette: (text: Color, background: Color) {
        switch score {
        case 0..<34:
            return (Color(hex: "#2F9E44"), Color(hex: "#ECFAF0"))
        case 34..<67:
            return (Color(hex: "#B77B00"), Color(hex: "#FFF7DA"))
        default:
            return (Color(hex: "#F04444"), Color(hex: "#FFF3F3"))
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(
                cornerRadius: 12.scale,
                style: .continuous
            )
            .fill(palette.background)
            .shadow(
                color: Color(hex: "#0E0E0E"),
                radius: 0,
                x: 2.scale,
                y: 2.scale
            )

            Text(title)
                .font(Tokens.Font.medium16)
                .foregroundStyle(palette.text)
                .padding(.horizontal, 10.scale)
                .padding(.vertical, 12.scale)
        }
        .fixedSize(horizontal: true, vertical: true)
    }

}
