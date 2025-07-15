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
    
    static let sampleContact = Contact(name: "Элина Петрова", contactType: "коллега", isNewContact: true, imageName: "globe", lastMessage: testDate, countMessages: 3, phone: "+7 (999) 999-99-99", birthday: testDate, connectChannels: connectChannels)

    static let connectChannels = [
        ConnectChannel(socialMediaType: .email, login: "test@example.com"),
        ConnectChannel(socialMediaType: .facebook, login: "fbSamka"),
        ConnectChannel(socialMediaType: .instagram, login: "InstaSamka"),
        ConnectChannel(socialMediaType: .linkedin, login: "LinkedInSamka"),
        ConnectChannel(socialMediaType: .teams, login: "TeamSamka"),
        ConnectChannel(socialMediaType: .vk, login: "VKSamka"),
        ConnectChannel(socialMediaType: .xTwitter, login: "twitterSamka")
    ]
    
    static let contacts = [
        Contact(name: "Элина Петрова", contactType: "коллега", isNewContact: true, imageName: "globe", lastMessage: testDate, countMessages: 3, phone: "+7 (999) 999-99-99", birthday: testDate, connectChannels: connectChannels)
    ]
}
