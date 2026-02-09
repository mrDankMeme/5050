//
//  PermissionsManagerImpl.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//

import Foundation
import AppTrackingTransparency
import AdSupport
import Photos
import AVFoundation
import UserNotifications

final class PermissionsManagerImpl: PermissionsManager {

    // MARK: - Status
    func status(of permission: Permission) async -> PermissionStatus {
        switch permission {
        case .tracking:
            if #available(iOS 14, *) {
                
                switch ATTrackingManager.trackingAuthorizationStatus {
                case .authorized:    return .authorized
                case .denied:        return .denied
                case .restricted:    return .restricted
                case .notDetermined: return .notDetermined
                @unknown default:    return .temporarilyUnavailable
                }
            } else {
                return .unsupported
            }

        case .notifications:
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral: return .authorized
            case .denied:        return .denied
            case .notDetermined: return .notDetermined
            @unknown default:    return .temporarilyUnavailable
            }

        case .photoLibrary:
            let s = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            switch s {
            case .authorized, .limited: return .authorized
            case .denied:        return .denied
            case .restricted:    return .restricted
            case .notDetermined: return .notDetermined
            @unknown default:    return .temporarilyUnavailable
            }

        case .camera:
            let s = AVCaptureDevice.authorizationStatus(for: .video)
            switch s {
            case .authorized:    return .authorized
            case .denied:        return .denied
            case .restricted:    return .restricted
            case .notDetermined: return .notDetermined
            @unknown default:    return .temporarilyUnavailable
            }

        case .files:
            return .authorized
        }
    }

    // MARK: - Request
    func request(_ permission: Permission) async -> PermissionStatus {
        switch permission {
        case .tracking:
            if #available(iOS 14, *) {
                let current = await status(of: .tracking)
                if current != .notDetermined { return current }

                
                let result: PermissionStatus = await withCheckedContinuation { (cont: CheckedContinuation<PermissionStatus, Never>) in
                    ATTrackingManager.requestTrackingAuthorization { status in
                        let mapped: PermissionStatus
                        switch status {
                        case .authorized:    mapped = .authorized
                        case .denied:        mapped = .denied
                        case .restricted:    mapped = .restricted
                        case .notDetermined: mapped = .notDetermined
                        @unknown default:    mapped = .temporarilyUnavailable
                        }
                        cont.resume(returning: mapped)
                    }
                }

                
                _ = ASIdentifierManager.shared().advertisingIdentifier
                return result
            } else {
                return .unsupported
            }

        case .notifications:
            let current = await status(of: .notifications)
            if current != .notDetermined { return current }
            do {
                let granted = try await UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert, .badge, .sound])
                return granted ? .authorized : .denied
            } catch {
                return .temporarilyUnavailable
            }

        case .photoLibrary:
            let current = await status(of: .photoLibrary)
            if current != .notDetermined { return current }
            return await withCheckedContinuation { (cont: CheckedContinuation<PermissionStatus, Never>) in
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { s in
                    let mapped: PermissionStatus
                    switch s {
                    case .authorized, .limited: mapped = .authorized
                    case .denied:               mapped = .denied
                    case .restricted:           mapped = .restricted
                    case .notDetermined:        mapped = .notDetermined
                    @unknown default:           mapped = .temporarilyUnavailable
                    }
                    cont.resume(returning: mapped)
                }
            }

        case .camera:
            let current = await status(of: .camera)
            if current != .notDetermined { return current }
            let granted = await withCheckedContinuation { (cont: CheckedContinuation<Bool, Never>) in
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    cont.resume(returning: granted)
                }
            }
            return granted ? .authorized : .denied

        case .files:
            return .authorized
        }
    }
}
