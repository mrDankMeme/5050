//
//  SearchGrid.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/19/25.
//

 

import SwiftUI

struct SearchGrid: View {
    let items: [HistoryRecord]
    let onTap: (HistoryRecord) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]

    var body: some View {
        if items.isEmpty {
            ContentUnavailableView(
                "No history yet",
                systemImage: "photo.on.rectangle",
                description: Text("Run a face search to see it here.")
            )
            .padding(.top, Tokens.Spacing.x24)
        } else {
            ScrollView {
                LazyVGrid(columns: columns, alignment: .center, spacing: Tokens.Spacing.x16) {
                    ForEach(items) { rec in
                        Button { onTap(rec) } label: {
                            SearchTile(rec: rec)
                                .padding(.horizontal, 8.scale)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(OpacityTapButtonStyle())
                    }
                }
                .padding(.top, 16.scale)
                .padding(.horizontal, Tokens.Spacing.x16)
                .padding(.bottom, Tokens.Spacing.x24)
            }
            .background(Color.clear)
        }
    }
}
