//
//  Baby.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import Foundation
import SwiftData

@Model
final class Baby {
    var id: UUID
    var name: String
    var birthday: Date
    var gender: Gender
    var photoData: Data?
    
    // Latest measurements
    var latestWeight: Double? // in grams
    var latestHeight: Double? // in cm
    var latestHeadCircumference: Double? // in cm
    
    init(name: String, birthday: Date, gender: Gender, photoData: Data? = nil) {
        self.id = UUID()
        self.name = name
        self.birthday = birthday
        self.gender = gender
        self.photoData = photoData
    }
    
    var age: String {
        let components = Calendar.current.dateComponents([.day], from: birthday, to: Date())
        guard let days = components.day else { return "" }
        
        if days < 30 {
            return "\(days) 天"
        } else if days < 365 {
            let months = days / 30
            return "\(months) 个月"
        } else {
            let years = days / 365
            let months = (days % 365) / 30
            return "\(years) 岁 \(months) 个月"
        }
    }
}

enum Gender: String, Codable {
    case male = "male"
    case female = "female"
    case other = "other"
}
