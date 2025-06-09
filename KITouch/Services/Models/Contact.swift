//
//  Contact.swift
//  KITouch
//
//  Created by Роман Вертячих on 30.05.2025.
//

import Foundation

struct Contact: Hashable, Identifiable {
    var id = UUID()
    
    var name: String
    var contactType: String
    var customContactType: String = ""
    let imageName: String
    let lastMessage: Date
    let countMessages: Int
    var phone: String
    var birthday: Date
    var connectChannels: [ConnectChannel]
    
    var displayContactType: String {
        contactType == ContactType.other.rawValue ? customContactType : contactType
    }
    
    init(name: String, contactType: String, imageName: String, lastMessage: Date, countMessages: Int, phone: String, birthday: Date, connectChannels: [ConnectChannel]) {
        self.name = name
        self.contactType = contactType
        self.customContactType = ""
        self.imageName = imageName
        self.lastMessage = lastMessage
        self.countMessages = countMessages
        self.phone = phone
        self.birthday = birthday
        self.connectChannels = connectChannels
    }
    
    init() {
        self.id = UUID()
        self.name = ""
        self.contactType = ""
        self.customContactType = ""
        self.imageName = "person"
        self.lastMessage = Date.distantPast
        self.countMessages = 0
        self.phone = ""
        self.birthday = Date(timeIntervalSince1970: 0)
        self.connectChannels = [ConnectChannel(socialMediaType: .email, login: "")]
    }
}

enum ContactType: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    var localizedValue: String { rawValue.localized() }
    
    case relative = "Relative"
    case colleague = "Colleague"
    case friend = "Friend"
    case unknown = "Unknown"
    
    case other = "Other"
}
