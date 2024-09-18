//
//  UIWindowScene+Extensions.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 18.09.24.
//

import UIKit

extension UIWindowScene {
    static var current: UIWindowScene? {
        return UIApplication
            .shared
            .connectedScenes
            .first { $0 is UIWindowScene } as? UIWindowScene
        
    }
    
    var screenHeight: CGFloat {
        UIWindowScene.current?.screen.bounds.height ?? 0
    }
    
    var screenWidth: CGFloat {
        UIWindowScene.current?.screen.bounds.width ?? 0
    }
}
