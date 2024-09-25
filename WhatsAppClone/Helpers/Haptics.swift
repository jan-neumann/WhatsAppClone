//
//  Haptics.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 25.09.24.
//

import UIKit

enum Haptics {
    static func impact(_ style: Style) {
        switch style {
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
    }
    
    enum Style {
        case light
        case medium
        case heavy
        case error
        case success
        case warning
    }
}
