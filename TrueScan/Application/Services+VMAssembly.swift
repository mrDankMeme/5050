//  Services+VMAssembly.swift
//  TrueScan
//

import Foundation
import Swinject
import UIKit

final class ServicesAssembly: Assembly {
    
    func assemble(container: Container) {
        
        // MARK: - Infrastructure
        
        container.register(APIConfig.self) { _ in
            APIConfig(baseURL: URL(string: "https://cheaterbuster.webberapp.shop")!)
        }
        .inObjectScope(.container)
        
        container.register(TokenStorage.self) { _ in
            KeychainTokenStorage()
        }
        .inObjectScope(.container)
        
        container.register(HTTPClient.self) { _ in
            URLSessionHTTPClient()
        }
        .inObjectScope(.container)
        
        // MARK: - App router
        
        container.register(AppRouter.self) { _ in
            AppRouter()
        }
        .inObjectScope(.container)
        
        // MARK: - Domain / Auth
        
        container.register(AuthRepository.self) { r in
            let cfg    = r.resolve(APIConfig.self)!
            let http   = r.resolve(HTTPClient.self)!
            let tokens = r.resolve(TokenStorage.self)!
            return AuthRepositoryImpl(cfg: cfg, http: http, tokens: tokens)
        }
        .inObjectScope(.container)
        
        // MARK: - Domain / API
        
        container.register(CheaterAPI.self) { r in
            let cfg    = r.resolve(APIConfig.self)!
            let http   = r.resolve(HTTPClient.self)!
            let tokens = r.resolve(TokenStorage.self)!
            return CheaterAPIImpl(cfg: cfg, http: http, tokens: tokens)
        }
        .inObjectScope(.container)
        
        // MARK: - Domain / Tasks
        
        container.register(TaskPoller.self) { r in
            let api = r.resolve(CheaterAPI.self)!
            return TaskPollerImpl(api: api)
        }
        .inObjectScope(.container)
        
        // MARK: - Stores
        
        container.register(HistoryStore.self) { _ in
            HistoryStoreImpl()
        }
        .inObjectScope(.container)
        
        container.register(CheaterStore.self) { _ in
            CheaterStoreImpl()
        }
        .inObjectScope(.container)
        
        container.register(SettingsStore.self) { _ in
            SettingsStoreImpl()
        }
        .inObjectScope(.container)

        container.register(LocationHistoryStore.self) { _ in
            LocationHistoryStoreImpl()
        }
        .inObjectScope(.container)
        
        // MARK: - PremiumStore
        
        container.register(PremiumStore.self) { _ in
            PremiumStoreImpl()
        }
        .inObjectScope(.container)
        
        // MARK: - Subscriptions
        
#if DEBUG
        container.register(SubscriptionService.self) { r in
            let premium = r.resolve(PremiumStore.self)!
            
            let bundleID = Bundle.main.bundleIdentifier ?? ""
            let productionBundleID = "com.vit.5007ch4at4r"
            
            if bundleID == productionBundleID {
                return MainActor.assumeIsolated {
                    SubscriptionServiceApphud(store: premium)
                }
            } else {
                return SubscriptionServiceStub(store: premium)
            }
        }
        .inObjectScope(.container)
#else
        container.register(SubscriptionService.self) { r in
            let premium = r.resolve(PremiumStore.self)!
            return MainActor.assumeIsolated {
                SubscriptionServiceApphud(store: premium)
            }
        }
        .inObjectScope(.container)
#endif
        
        // MARK: - Domain / Search
        
        container.register(SearchRepository.self) { r in
            let api = r.resolve(CheaterAPI.self)!
            return SearchRepositoryImpl(api: api)
        }
        .inObjectScope(.container)
        
        // MARK: - App Lock
            
            container.register(AppLockStore.self) { _ in
                AppLockStoreImpl()
            }
            .inObjectScope(.container)
        
        // MARK: - Services
        
        container.register(SearchService.self) { r in
            let repo   = r.resolve(SearchRepository.self)!
            let poller = r.resolve(TaskPoller.self)!
            let auth   = r.resolve(AuthRepository.self)!
            return SearchServiceImpl(repo: repo, poller: poller, auth: auth)
        }
        .inObjectScope(.container)
        
        container.register(CheaterAnalyzerService.self) { _ in
            CheaterAnalyzerServiceImpl()
        }
        .inObjectScope(.container)
        
        // MARK: - ViewModels
        
        container.register(SearchViewModel.self) { r in
            let history  = r.resolve(HistoryStore.self)!
            let settings = r.resolve(SettingsStore.self)!
            let search   = r.resolve(SearchService.self)!
            return SearchViewModel(search: search, history: history, settings: settings)
        }
        
        container.register(HistoryViewModel.self) { r in
            let store         = r.resolve(HistoryStore.self)!
            let cheaterStore  = r.resolve(CheaterStore.self)!
            let locationStore = r.resolve(LocationHistoryStore.self)!   // NEW
            let search        = r.resolve(SearchService.self)!
            return HistoryViewModel(
                store: store,
                cheaterStore: cheaterStore,
                locationStore: locationStore,
                search: search
            )
        }
        .inObjectScope(.container)
        
        container.register(CheaterViewModel.self) { r in
            let auth   = r.resolve(AuthRepository.self)!
            let api    = r.resolve(CheaterAPI.self)!
            let poller = r.resolve(TaskPoller.self)!
            let store  = r.resolve(CheaterStore.self)!
            let cfg    = r.resolve(APIConfig.self)!
            return CheaterViewModel(auth: auth, api: api, poller: poller, store: store, cfg: cfg)
        }
        .inObjectScope(.container)
        
        container.register(FindPlaceViewModel.self) { r in
                let auth   = r.resolve(AuthRepository.self)!
                let api    = r.resolve(CheaterAPI.self)!
                let poller = r.resolve(TaskPoller.self)!
                let cfg    = r.resolve(APIConfig.self)!
                return FindPlaceViewModel(auth: auth, api: api, poller: poller, cfg: cfg)
            }
        
        container.register(SettingsViewModel.self) { r in
            let store = r.resolve(SettingsStore.self)!
            return SettingsViewModel(store: store)
        }
        
        // MARK: - PaywallViewModel
        
        container.register(PaywallViewModel.self) { r in
            let subscription = r.resolve(SubscriptionService.self)!
            return PaywallViewModel(subscription: subscription)
        }
        .inObjectScope(.transient)
        
        // MARK: - Extra services
        
        container.register(PermissionsManager.self) { _ in
            PermissionsManagerImpl()
        }
        .inObjectScope(.container)
        
        // MARK: - Amplitude
        container.register(AnalyticsService.self) { _ in
            AmplitudeServiceImpl()
        }
        .inObjectScope(.container)
    }
}
