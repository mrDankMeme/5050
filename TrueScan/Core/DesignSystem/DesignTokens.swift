//
//  DesignTokens.swift
//  CheaterBuster
//

import SwiftUI

public enum Tokens {

    // MARK: Colors
    public enum Color {
        public static var accent: SwiftUI.Color { SwiftUI.Color("Accent") }
        public static var accentPressed: SwiftUI.Color { SwiftUI.Color("AccentPressed") }
        public static var blue: SwiftUI.Color { SwiftUI.Color("Blue") }
        public static var lightBlue: SwiftUI.Color { SwiftUI.Color("lightBlue") }
        public static var textPrimary: SwiftUI.Color { SwiftUI.Color("TextPrimary") }
        public static var textSecondary: SwiftUI.Color { SwiftUI.Color("TextSecondary") }

        public static var borderNeutral: SwiftUI.Color { SwiftUI.Color("BorderNeutral") }
        public static var backgroundMain: SwiftUI.Color { SwiftUI.Color("BackgroundMain") }
        public static var shadowBlack7: SwiftUI.Color { SwiftUI.Color("ShadowBlack7") }
        public static var surfaceCard: SwiftUI.Color { SwiftUI.Color("SurfaceCard") }
    }

    // MARK: Typography
    public enum Font {
        static var titleSemibold32: SwiftUI.Font { .custom("SFProDisplay-Semibold", size: 32.scale) }

        public static var h1: SwiftUI.Font { .custom("SFProDisplay-Semibold", size: 32.scale) }
        public static var h2: SwiftUI.Font { .custom("SFProDisplay-Medium",  size: 28.scale) }
        public static var title: SwiftUI.Font { .custom("SFProDisplay-Medium", size: 22.scale) }
        public static var subtitle: SwiftUI.Font { .custom("SFProDisplay-Bold", size: 20.scale) }
        public static var medium20: SwiftUI.Font { .custom("SFProDisplay-Medium", size: 20.scale) }
        

        public static var body: SwiftUI.Font { .custom("SFProText-Regular",  size: 20.scale) }
        public static var bodyMedium18: SwiftUI.Font { .custom("SFProText-Medium",   size: 18.scale) }
        public static var bodyMedium: SwiftUI.Font { .custom("SFProText-Medium",     size: 16.scale) }
        public static var medium12: SwiftUI.Font { .custom("SFProText-Medium",     size: 12.scale) }
        public static var caption: SwiftUI.Font { .custom("SFProText-Medium",        size: 15.scale) }
        public static var regular16: SwiftUI.Font { .custom("SFProText-Regular",        size: 16.scale) }
        public static var captionRegular: SwiftUI.Font { .custom("SFProText-Regular", size: 15.scale) }

        static var bodySemibold16: SwiftUI.Font { .custom("SFProDisplay-Semibold", size: 16.scale) }
        static var semibold13: SwiftUI.Font { .custom("SFProDisplay-Semibold", size: 13.scale) }
        static var bodySemibold20: SwiftUI.Font { .custom("SFProDisplay-Semibold", size: 20.scale) }
        static var titleMedium28: SwiftUI.Font { .custom("SFProDisplay-Medium", size: 28.scale) }
        static var bodyMedium16: SwiftUI.Font { .custom("SFProDisplay-Medium", size: 16.scale) }
        static var medium18: SwiftUI.Font { .custom("SFProDisplay-Medium", size: 18.scale) }
        static var medium16: SwiftUI.Font { .custom("SFProDisplay-Medium", size: 16.scale) }
        static var optionsMedium16: SwiftUI.Font { .custom("InterTight-Medium", size: 16.scale) }
        static var interTight16: SwiftUI.Font { .custom("InterTight-Medium", size: 16.scale) }
    }

    // MARK: Spacing & Radius
    public enum Spacing {
        public static var x4:  CGFloat { 4.scale  }
        public static var x8:  CGFloat { 8.scale  }
        public static var x12: CGFloat { 12.scale }
        public static var x16: CGFloat { 16.scale }
        public static var x20: CGFloat { 20.scale }
        public static var x24: CGFloat { 24.scale }
        public static var x32: CGFloat { 32.scale }
    }

    public enum Radius {
        public static var pill:   CGFloat { 24.scale }
        public static var medium: CGFloat { 16.scale }
        public static var small:  CGFloat { 12.scale }
    }

    // MARK: Shadow
    public enum Shadow {
        public static var card: ShadowStyle {
            ShadowStyle(
                color: .black.opacity(0.07),
                radius: 8.scale,
                y: 0.scale
            )
        }
    }
}

// MARK: Helpers
public struct ShadowStyle {
    public let color: Color
    public let radius: CGFloat
    public let y: CGFloat
}

public extension View {
    func apply(_ shadow: ShadowStyle) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: 0, y: shadow.y)
    }
}
