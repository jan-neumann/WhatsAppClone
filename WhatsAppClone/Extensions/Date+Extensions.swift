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
    
    func toString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    var relativeDateString: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else if isCurrentWeek {
            return toString(format: "EEEE") // monday
        } else if isCurrentYear {
            return toString(format: "E, MMM d") // Mon, Feb 19
        } else {
            return toString(format: "MMM dd, yyyy") // Mon, Feb 19, 2019
        }
    }
    
    private var isCurrentWeek: Bool {
        Calendar.current.isDate(self, equalTo: .now, toGranularity: .weekday)
    }
    
    private var isCurrentYear: Bool {
        Calendar.current.isDate(self, equalTo: .now, toGranularity: .year)
    }
    
    func isSameDay(as otherDate: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: otherDate)
    }
}
