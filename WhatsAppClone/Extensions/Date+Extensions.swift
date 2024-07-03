//
//  Date+Extensions.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 03.07.24.
//

import Foundation

extension Date {
    
    /// if today: h:mm PM/AM
    /// if yesterday: return "yesterday"
    /// else return  MM/dd/yy
    var dayOrTimeRepresentation: String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        
        if calendar.isDateInToday(self) {
            dateFormatter.dateFormat = "h:mm a"
            let formattedDate = dateFormatter.string(from: self)
            return formattedDate
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            dateFormatter.dateFormat = "MM/dd/yy"
            return dateFormatter.string(from: self)
        }
    }
    
    /// h:mm PM/AM
    var formatToTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let formattedTime = dateFormatter.string(from: self)
        return formattedTime
    }
}
