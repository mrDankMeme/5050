//
//  HomeFlowContainerView.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//



import SwiftUI
import Swinject

struct HomeFlowContainerView: View {
    let flow: HomeView.ActiveFlow
    let resolver: Resolver
    let onClose: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            Tokens.Color.backgroundMain
                .ignoresSafeArea()

            VStack(spacing: 0) {
                switch flow {
                case .search:
                    SearchScreen(
                        vm: resolver.resolve(SearchViewModel.self)!,
                        onClose: onClose
                    )

                case .cheater:
                    CheaterView(
                        vm: resolver.resolve(CheaterViewModel.self)!,
                        onClose: onClose
                    )

                case .findPlace:
                    FindPlaceView(onClose: onClose)
                }
            }
        }
        .edgeSwipeToPop(isEnabled: true) {
            onClose()
        }
    }
}
