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
    
    static let sampleContact = ContactResponse(name: "Элина Петрова", contactType: "коллега", imageName: "globe", lastMessage: testDate, countMessages: 3, phone: "+7 (999) 999-99-99", email: "e.petrova@example.com", birthday: testDate, networks: networks)
    
    static let networks = ["vk", "instagram", "facebook", "twitter", "test"]
    
    static let contacts = [
        ContactResponse(name: "Элина Петрова", contactType: "коллега", imageName: "globe", lastMessage: testDate, countMessages: 3, phone: "+7 (999) 999-99-99", email: "e.petrova@example.com", birthday: testDate, networks: networks),
        ContactResponse(name: "Иван Кузнецов", contactType: "коллега", imageName: "globe", lastMessage: testDate, countMessages: 2, phone: "+7 (999) 999-99-98", email: "i.kuznetcov@example.com", birthday: testDate, networks: networks),
        ContactResponse(name: "Павел Пирогов", contactType: "друг", imageName: "globe", lastMessage: testDate, countMessages: 0, phone: "+7 (999) 999-99-97", email: "p.pirogov@example.com", birthday: testDate, networks: networks),
        ContactResponse(name: "Эльвира Набиулина", contactType: "мама", imageName: "globe", lastMessage: testDate, countMessages: 1, phone: "+7 (999) 999-99-96", email: "e.nabiulina@example.com", birthday: testDate, networks: networks),
        ContactResponse(name: "Алексей Набиулин", contactType: "брат", imageName: "globe", lastMessage: testDate, countMessages: 5, phone: "+7 (999) 999-99-95", email: "a.nabiulin@example.com", birthday: testDate, networks: networks)
    ]
}
