// RateUsScheduler.swift
// TrueScan / CheaterBuster

import Foundation
import StoreKit
import UIKit

/// Единая точка управления RateUs:
/// - Custom RateUs (feedback popup): не чаще 1 раза в неделю, и никогда после "оценки".
/// - System RateUs (Apple SKStoreReviewController): запрашиваем только по 👍 и по своей политике (лимит/год и т.п.).
///
/// Важно: SKStoreReviewController.requestReview(...) не гарантирует показ — решает Apple.
final class RateUsScheduler {

    enum Reason: String {
        case searchResults
        case cheaterResults
        case findPlaceResults
    }

    static let shared = RateUsScheduler()
    private init() {}

    // MARK: - Notifications (UI listens to this)

    static let willPresentCustomNotification = Notification.Name("cb.rateus.custom.willPresent")

    // MARK: - Policy (tunable)

    /// Custom popup: не чаще, чем раз в неделю
    private let customMinDaysBetweenShows: Int = 7

    /// System request: не чаще 3 раз в год
    private let systemMaxRequestsPerYear: Int = 3

    /// System request: доп. защита по интервалу (чтобы не дергать часто даже внутри года)
    private let systemMinDaysBetweenRequests: Int = 14

    private let userDefaults = UserDefaults.standard

    // MARK: - Keys

    /// Если true — больше никогда не показываем Custom (и не просим System)
    private let kRatedForever = "cb.rateus.ratedForever"

    // Custom tracking
    private let kCustomLastShownAt = "cb.rateus.custom.lastShownAt"

    // System tracking
    private let kSystemLastRequestedAt = "cb.rateus.system.lastRequestedAt"
    private let kSystemRequestsInYear = "cb.rateus.system.requestsInYear"

    // MARK: - Public API

    /// Вызывай при успешных результатах (Search/FindPlace/etc).
    /// Scheduler сам решит: показать ли Custom popup.
    func requestCustom(_ reason: Reason) {
        guard canShowCustomNow() else { return }
        userDefaults.set(Date(), forKey: kCustomLastShownAt)
        NotificationCenter.default.post(name: Self.willPresentCustomNotification, object: nil)
    }

    /// Вызывай при закрытии Custom popup.
    /// - positive=false: 👎 или фон
    /// - positive=true: 👍 (тут же можем запросить System RateUs, если политика разрешает)
    func customDismissed(positive: Bool) {
        if positive {
            // Считаем, что пользователь "оценил" → Custom больше не показываем вообще.
            userDefaults.set(true, forKey: kRatedForever)

            // Пытаемся запросить System RateUs по отдельной политике.
            requestSystemIfAllowed()
        }
        // negative: ничего дополнительно не делаем.
        // CustomLastShownAt уже был записан в момент показа.
    }

    // MARK: - Custom policy

    private func canShowCustomNow() -> Bool {
        // если "оценка" была — больше никогда
        if userDefaults.bool(forKey: kRatedForever) { return false }

        // не чаще раза в неделю
        if let last = userDefaults.object(forKey: kCustomLastShownAt) as? Date {
            let days = Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 0
            if days < customMinDaysBetweenShows { return false }
        }

        return true
    }

    // MARK: - System policy

    private func requestSystemIfAllowed() {
        cleanupSystemYearIfNeeded()

        // лимит в год
        let yearCount = userDefaults.integer(forKey: kSystemRequestsInYear)
        if yearCount >= systemMaxRequestsPerYear { return }

        // интервал между попытками
        if let last = userDefaults.object(forKey: kSystemLastRequestedAt) as? Date {
            let days = Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 0
            if days < systemMinDaysBetweenRequests { return }
        }

        // делаем попытку
        requestSystemReviewInForegroundScene()

        // фиксируем попытку (даже если Apple не покажет — мы все равно не спамим)
        userDefaults.set(Date(), forKey: kSystemLastRequestedAt)
        userDefaults.set(yearCount + 1, forKey: kSystemRequestsInYear)
    }

    private func cleanupSystemYearIfNeeded() {
        guard let last = userDefaults.object(forKey: kSystemLastRequestedAt) as? Date else { return }
        let days = Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 0
        if days > 365 {
            userDefaults.set(0, forKey: kSystemRequestsInYear)
        }
    }

    private func requestSystemReviewInForegroundScene() {
        DispatchQueue.main.async {
            guard let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }) else {
                return
            }
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
