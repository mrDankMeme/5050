// Domain/Stores/PremiumStore.swift

import Foundation

public protocol PremiumStore: AnyObject {
    var isPremium: Bool { get set }
}
