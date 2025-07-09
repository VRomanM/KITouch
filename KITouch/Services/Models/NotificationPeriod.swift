//
//  NotificationPeriod.swift
//  KITouch
//
//  Created by Роман Вертячих on 08.07.2025.
//

import Foundation

enum NotificationPeriod: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    var localizedValue: String { rawValue.localized() }
    
    case daily      = "Daily"
    case weekly     = "Weekly"
    case monthly    = "Monthly"
    case halfYearly = "Every 6 months"
    case yearly     = "Yearly"
    case never      = "Never"
    
    var repeatInterval: Calendar.Component? {
        switch self {
        case .never: return nil
        case .daily: return .day
        case .weekly: return .weekOfYear
        case .monthly: return .month
        case .halfYearly: return .month // Handle specially with 6 month interval
        case .yearly: return .year
        }
    }
}
