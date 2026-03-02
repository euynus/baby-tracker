//
//  TimeInterval+Formatting.swift
//  BabyTracker
//

import Foundation

extension TimeInterval {
    /// Formats the duration as "H:MM:SS"
    func formatHHMMSS() -> String {
        let total = Int(self)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }

    /// Formats the duration as "MM:SS" or "M:SS"
    /// - Parameter leadingZero: Whether to include a leading zero for minutes if they are less than 10.
    func formatMMSS(leadingZero: Bool = true) -> String {
        let total = Int(self)
        let minutes = total / 60
        let seconds = total % 60
        let format = leadingZero ? "%02d:%02d" : "%d:%02d"
        return String(format: format, minutes, seconds)
    }
}
