//
//  Contact.swift
//  KITouch
//
//  Created by Роман Вертячих on 30.05.2025.
//

import Foundation

struct Contact: Hashable, Identifiable {
    var id = UUID()
    
    let name: String
    let contactType: String
    let imageName: String
    let lastMessage: Date
    let countMessages: Int
    let phone: String
    let birthday: Date
    var connectChannels: [ConnectChannel]
}
