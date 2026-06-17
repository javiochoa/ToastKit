//
//  UIAccessibiltiy.swift
//  ToastKit
//
//  Created by Javier Gómez Ochoa on 17/06/2026.
//
import Foundation
import UIKit

extension UIAccessibility {
    @MainActor static func setFocusTo(_ object: Any?, inTime: CGFloat = 0.2, notification: UIAccessibility.Notification = .layoutChanged) {
        if UIAccessibility.isVoiceOverRunning {
            DispatchQueue.main.asyncAfter(deadline: .now() + inTime) {
                UIAccessibility.post(notification: notification, argument: object)
            }
        }
    }

    /// Posts an accessibility announcement using VoiceOver.
    /// This method checks if VoiceOver is currently running, and if so,
    /// posts an accessibility announcement after a short delay.
    /// This is useful for alerting users with visual impairments to changes in the app's state or other important information.
    /// - Parameter announcement: The message to be spoken by VoiceOver.
    @MainActor static func announce(_ announcement: String) {
        if UIAccessibility.isVoiceOverRunning {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UIAccessibility.post(
                    notification: .announcement,
                    argument: NSString(string: announcement)
                )
            }
        }
    }
}
