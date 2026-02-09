//
//  CheaterList.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/19/25.
//

 

import SwiftUI

struct CheaterList: View {
    let items: [CheaterRecord]
    let onTap: (CheaterRecord) -> Void

    var body: some View {
        if items.isEmpty {
            ContentUnavailableView(
                "No cheater items yet",
                systemImage: "text.magnifyingglass",
                description: Text("Analyze a chat to see it here.")
            )
            .padding(.top, Tokens.Spacing.x24)
        } else {
            ScrollView {
                LazyVStack(spacing: Tokens.Spacing.x12) {
                    ForEach(items) { rec in
                        Button { onTap(rec) } label: {
                            CheaterRow(rec: rec)
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
