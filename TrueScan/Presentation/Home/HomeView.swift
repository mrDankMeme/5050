//
//  HomeView.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//

import SwiftUI
import Swinject

struct HomeView: View {
    @Environment(\.resolver) private var resolver

    enum ActiveFlow: Equatable {
        case search
        case cheater
        case findPlace
    }

    @State private var activeFlow: ActiveFlow? = nil

    var body: some View {
        ZStack {
            HomeMainContentView(activeFlow: $activeFlow)

            if let flow = activeFlow {
                HomeFlowContainerView(
                    flow: flow,
                    resolver: resolver,
                    onClose: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            activeFlow = nil
                        }
                    }
                )
                .transition(.move(edge: .trailing))
                .shadow(
                    color: Color.black.opacity(0.03),
                    radius: 2,
                    x: -1,
                    y: 0
                )
                .zIndex(10)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.9), value: activeFlow)
        .toolbar(activeFlow != nil ? .hidden : .visible, for: .tabBar)
    }
}
