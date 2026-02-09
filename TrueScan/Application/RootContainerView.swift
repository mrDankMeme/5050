// Application/RootContainerView.swift
//
//  RootContainerView.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//

import SwiftUI

struct RootContainerView: View {

    @State private var showSplash: Bool = true

    // MARK: - App Lock (Step 4)
    @StateObject private var appLock = AppLockViewModel()
    @Environment(\.scenePhase) private var scenePhase

    // Чтобы не ломать онбординг: lock показываем только когда онбординг завершён
    @AppStorage("cb.hasOnboarded") private var hasOnboarded = false

    var body: some View {
        ZStack {

            // Основное приложение
            RootTabView(isSplashActive: showSplash)
                .opacity(showSplash ? 0 : 1)

            // Splash
            if showSplash {
                SplashLoadingView {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        showSplash = false
                    }
                }
                .transition(.opacity)
            }

            // MARK: - Lock overlay (выше приложения, но ниже Splash)
            if shouldShowLock {
                LockScreenView()
                    .environmentObject(appLock)
                    .transition(.opacity)
                    .zIndex(50)
            }
        }
        .onAppear {
            // На всякий: если lock выключили в настройках — отпустим
            appLock.syncPrefs()
        }
        .onChange(of: showSplash) { _, isSplash in
            // Как только splash ушёл — это “холодный старт UI”.
            // Если lock включён — должны запросить passcode/FaceID.
            if isSplash == false {
                appLock.lockIfNeeded()
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background {
                // Ушел в фон — лочим
                appLock.lockIfNeeded()
            }

            if phase == .active {
                // Возврат в актив — НЕ лочим заново (иначе будет луп после FaceID),
                // только синкаем prefs (если lock выключили/сбросили passcode — отпустит).
                appLock.syncPrefs()
            }
        }
    }

    private var shouldShowLock: Bool {
        // пока splash — не мешаем
        guard showSplash == false else { return false }
        // пока онбординг — тоже не мешаем
        guard hasOnboarded == true else { return false }
        // включён ли lock + есть ли код
        guard AppLockPrefs.isEnabled(), AppLockPrefs.hasPasscode() else { return false }
        // и сейчас закрыто
        return appLock.isUnlocked == false
    }
}
