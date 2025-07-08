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
    
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
}
