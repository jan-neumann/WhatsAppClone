//
//  TimeInterval+Extensions.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 12.09.24.
//

import Foundation

extension TimeInterval {
    var formatElapsedTime: String {
        let minutes = Int(self / 60)
        let seconds = Int(self.truncatingRemainder(dividingBy: 60))
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    static var stubTimeInterval: TimeInterval { 0.0 }
}

