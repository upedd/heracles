//
//  date.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 17/02/2025.
//

import Foundation

extension Range<Date> {
    var midpoint: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.second], from: lowerBound, to: upperBound)
        
        return calendar.date(byAdding: .second, value: components.second! / 2, to: lowerBound)!
    }
}

extension Date {
    func roundToNearestHour() -> Date {
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: self)
        
        let roundedDate: Date
        if minutes >= 30 {
            // Round up to the next hour
            roundedDate = calendar.date(byAdding: .hour, value: 1, to: self)!
        } else {
            // Round down to the current hour
            roundedDate = self
        }
        
        // Strip minutes & seconds
        return calendar.date(bySettingHour: calendar.component(.hour, from: roundedDate),
                             minute: 0,
                             second: 0,
                             of: roundedDate)!
    }
}
