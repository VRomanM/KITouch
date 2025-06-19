//
//  ContactType.swift
//  KITouch
//
//  Created by Роман Вертячих on 11.06.2025.
//

import Foundation

enum ContactType: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    var localizedValue: String { NSLocalizedString(rawValue, comment: "") }
    
    case relative = "Relative"
    case colleague = "Colleague"
    case friend = "Friend"
    case unknown = "Unknown"
    case other = "Other"
}
