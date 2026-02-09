//
//  ThreeDotsLoaderBlue.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//




import SwiftUI

struct ThreeDotsLoaderBlue: View {
    @State private var activeIndex: Int = 0

    private let big: CGFloat = 16
    private let mid: CGFloat = 8
    private let small: CGFloat = 4
    private let count: Int = 3

    private let timer = Timer.publish(every: 0.35, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 8.scale) {
            ForEach(0..<count, id: \.self) { idx in

                let dist = (idx - activeIndex + count) % count

                let size: CGFloat =
                    dist == 0 ? big :
                    dist == 1 ? mid :
                    small

                let opacity: Double =
                    dist == 0 ? 1.0 :
                    dist == 1 ? 0.6 :
                    0.3

                Circle()
                    .fill(Tokens.Color.blue.opacity(opacity))
                    .shadow(
                        color: Color.black.opacity(0.35),
                        radius: 0,
                        x: 2.scale,
                        y: 2.scale
                    )
                    .frame(width: size.scale, height: size.scale)
                    .animation(.easeOut(duration: 0.35), value: activeIndex)
            }
        }
        .onReceive(timer) { _ in
            activeIndex = (activeIndex + 1) % count
        }
    }
}
