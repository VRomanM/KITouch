//
//  SocialMediaType.swift
//  KITouch
//
//  Created by Роман Вертячих on 11.06.2025.
//

import Foundation

enum SocialMediaType: String, CaseIterable, Identifiable {
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
            "FB"
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
