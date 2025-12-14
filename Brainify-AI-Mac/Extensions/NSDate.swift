//
//  NSDate.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 14/12/2025.
//


import Cocoa

extension Date {
    func timeString() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short  // e.g., 2:34 PM or 9:00 AM
        formatter.locale = Locale.current
        return formatter.string(from: self)
    }
    
    func relativeDayString() -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(self) {
            return "Today".localized()
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday".localized()
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium  // e.g., Nov 11, 2025 (locale ke hisaab se)
            formatter.timeStyle = .none
            formatter.locale = Locale.current
            return formatter.string(from: self)
        }
    }
}
