// Presentation/FindAPlace/FindPlaceView/FindPlaceView.swift
// TrueScan

import SwiftUI
import Swinject

struct FindPlaceView: View {

    @Environment(\.resolver) private var resolver
    let onClose: () -> Void

    var body: some View {
        let vm = resolver.resolve(FindPlaceViewModel.self)!
        FindPlaceCoordinatorView(vm: vm, onClose: onClose)
    }
}
