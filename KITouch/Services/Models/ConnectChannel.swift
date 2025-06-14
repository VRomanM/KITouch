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
