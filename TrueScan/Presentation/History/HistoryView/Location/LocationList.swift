//
//  LocationList.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/19/25.
//


 

import SwiftUI

struct LocationList: View {
    let items: [LocationHistoryItem]
    let onTap: (LocationHistoryItem) -> Void

    var body: some View {
        if items.isEmpty {
            ContentUnavailableView(
                "No location history yet",
                systemImage: "mappin.and.ellipse",
                description: Text("Use Find Place to see it here.")
            )
            .padding(.top, Tokens.Spacing.x24)
        } else {
            ScrollView {
                LazyVStack(spacing: Tokens.Spacing.x12) {
                    ForEach(items) { item in
                        Button { onTap(item) } label: {
                            LocationRow(item: item)
                                .padding(.horizontal, Tokens.Spacing.x16)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(OpacityTapButtonStyle())
                    }
                }
                .padding(.top, Tokens.Spacing.x16)
                .padding(.bottom, Tokens.Spacing.x24)
            }
            .background(Color.clear)
        }
    }
}
