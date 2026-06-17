//
//  AccessibilityHelper.swift
//  ToastKit
//
//  Created by Javier Gómez Ochoa on 17/06/2026.
//


import UIKit

struct AccessibilityHelper {
    static let simulateVoiceOverKey = "simulateVoiceOver"

    static let isVoiceOverRunning: Bool = {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: simulateVoiceOverKey) != nil,
           defaults.bool(forKey: simulateVoiceOverKey) == true {
            return true
        }
        return UIAccessibility.isVoiceOverRunning
    }()

    static func updateVoiceOverStatus(to enabled: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(enabled, forKey: simulateVoiceOverKey)
        defaults.synchronize()
    }
}
