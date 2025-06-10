//
//  ConnectChannel.swift
//  KITouch
//
//  Created by Роман Вертячих on 03.06.2025.
//

import Foundation

struct ConnectChannel: Hashable, Identifiable {
    var id = UUID()
    
    var socialMediaType: SocialMediaType
    var login: String
}

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
