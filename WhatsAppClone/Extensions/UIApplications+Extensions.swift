//
//  UIApplications+Extensions.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 18.09.24.
//

import UIKit

extension UIApplication {
    static func dismissKeyboard() {
        UIApplication
            .shared
            .sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
