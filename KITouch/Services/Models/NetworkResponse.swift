//
//  NetworkResponse.swift
//  KITouch
//
//  Created by Роман Вертячих on 03.06.2025.
//

import Foundation

struct NetworkResponse: Hashable, Identifiable {
    var id = UUID()
    
    var network: Network
    var login: String
}

enum Network: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    
    case vk = "VK"
    case facebook = "facebook"
    case instagram = "instagram"
    case xTwitter = "X"
    case linkedin = "linkedin"
    case teams = "teams"
    case email = "e-mail"
    
    var icon: String {
        switch self {
        case .vk:
            "vk"
        case .facebook:
            "fb"
        case .instagram:
            "instagram"
        case .xTwitter:
            "X-twitter"
        case .linkedin:
            "linkedin"
        case .teams:
            "teams"
        case .email:
            "email"
        }
    }
}
