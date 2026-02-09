// Presentation/History/Components/SegmentCapsule.swift
// CheaterBuster

import SwiftUI

struct SegmentCapsule: View {
    @Binding var selected: HistoryViewModel.Segment
    @ObservedObject var router: AppRouter

    var body: some View {
        ZStack {
          //  RoundedRectangle(cornerRadius: 22.scale, style: .continuous)
          //      .fill(Tokens.Color.surfaceCard)
          //      .apply(Tokens.Shadow.card)

            HStack(spacing: 8.scale ) {
                seg("Search", .search)
                seg("Cheater", .cheater)
                seg("Location", .location) // NEW
            }
        }
        .frame(height: 44.scale)
    }

    private func seg(_ title: String, _ seg: HistoryViewModel.Segment) -> some View {
        Button {
            selected = seg
            router.rememberHistorySegment(seg)
        } label: {
            Text(title)
                .font(Tokens.Font.caption)
                .foregroundStyle(selected == seg ? .white : Tokens.Color.textPrimary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    Group {
                        if selected == seg {
                            RoundedRectangle(cornerRadius: 12.scale, style: .continuous)
                                .fill(Tokens.Color.accent)
                                .shadow(
                                    color: Color.black,
                                    radius: 0,
                                    x: 2.scale,
                                    y: 2.scale
                                )
                        } else {
                            RoundedRectangle(cornerRadius: 12.scale, style: .continuous)
                                .fill(Color.white)
                        }
                    }
                )
        }
        .buttonStyle(OpacityTapButtonStyle())
    }
}
