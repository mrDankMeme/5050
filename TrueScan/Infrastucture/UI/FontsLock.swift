//
//  FontsLockModifier.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 11/6/25.
//

import SwiftUI

public struct FontsLock: ViewModifier {
    public init() {}
    public func body(content: Content) -> some View {
        content
            .environment(\.dynamicTypeSize, .large)
            .environment(\.legibilityWeight, .regular)
    }
}

public extension View {
    
    func lockFonts() -> some View {
        modifier(FontsLock())
    }
}
