//
//  MocData.swift
//  KITouch
//
//  Created by Роман Вертячих on 30.05.2025.
//

import Foundation

struct MocData {
    static let testDate: Date = {
        var components = DateComponents()
        components.day = 7
        components.month = 10
        components.year = 2024
        return Calendar.current.date(from: components) ?? Date()
    }()
    
    static let sampleContact = ContactResponse(name: "Элина Петрова", contactType: "коллега", imageName: "globe", lastMessage: testDate, countMessages: 3, phone: "+7 (999) 999-99-99", birthday: testDate, networks: networks)
    
    static let networks = [
        NetworkResponse(network: .email, login: "test@example.com"),
        NetworkResponse(network: .facebook, login: "fbSamka"),
        NetworkResponse(network: .instagram, login: "InstaSamka"),
        NetworkResponse(network: .linkedin, login: "LinkedInSamka"),
        NetworkResponse(network: .teams, login: "TeamSamka"),
        NetworkResponse(network: .vk, login: "VKSamka"),
        NetworkResponse(network: .xTwitter, login: "twitterSamka")
    ]
    
    static let contacts = [
        ContactResponse(name: "Элина Петрова", contactType: "коллега", imageName: "globe", lastMessage: testDate, countMessages: 3, phone: "+7 (999) 999-99-99", birthday: testDate, networks: networks),
        ContactResponse(name: "Иван Кузнецов", contactType: "коллега", imageName: "globe", lastMessage: testDate, countMessages: 2, phone: "+7 (999) 999-99-98", birthday: testDate, networks: networks),
        ContactResponse(name: "Павел Пирогов", contactType: "друг", imageName: "globe", lastMessage: testDate, countMessages: 0, phone: "+7 (999) 999-99-97", birthday: testDate, networks: networks),
        ContactResponse(name: "Эльвира Набиулина", contactType: "мама", imageName: "globe", lastMessage: testDate, countMessages: 1, phone: "+7 (999) 999-99-96", birthday: testDate, networks: networks),
        ContactResponse(name: "Алексей Набиулин", contactType: "брат", imageName: "globe", lastMessage: testDate, countMessages: 5, phone: "+7 (999) 999-99-95", birthday: testDate, networks: networks)
    ]
}
