//
//  Contact.swift
//  KITouch
//
//  Created by Роман Вертячих on 30.05.2025.
//

import Foundation

struct Contact: Hashable, Identifiable {
    var id = UUID()
    var idString: String { id.uuidString }
    
    var name: String
    var contactType: String
    var customContactType: String = ""
    var imageName: String
    var lastMessage: Date?
    var countMessages: Int
    var phone: String
    var birthday: Date?
    var connectChannels: [ConnectChannel]
    var isNotSaved: Bool
    var reminder: Bool = false
    var reminderDate: Date
    var reminderRepeat: String = "Monthly"
    var reminderBirthday: Bool = false
    var reminderBeforeBirthday: Bool = false
    var reminderCountDayBeforeBirthday: Int = 1
    var systemContactId: String?
    
    var displayContactType: String {
        contactType == ContactType.other.rawValue ? customContactType : contactType
    }
    
    var isFromSystemContacts: Bool {
        systemContactId != nil
    }
    
    init(name: String, contactType: String, isNewContact: Bool, imageName: String, lastMessage: Date, countMessages: Int, phone: String, birthday: Date?, connectChannels: [ConnectChannel], systemContactId: String? = nil) {
        self.name = name
        self.contactType = contactType
        self.customContactType = ""
        self.imageName = imageName
        self.lastMessage = lastMessage
        self.countMessages = countMessages
        self.phone = phone
        self.birthday = birthday
        self.reminderDate = Date.now
        self.connectChannels = connectChannels
        self.isNotSaved = isNewContact
        self.systemContactId = systemContactId
    }
    
    init() {
        self.name = ""
        self.contactType = ""
        self.customContactType = ""
        self.imageName = "😎"
        self.lastMessage = nil
        self.countMessages = 0
        self.phone = ""
        self.reminderDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        self.connectChannels = [ConnectChannel(socialMediaType: .email, login: "")]
        self.isNotSaved = true
        self.systemContactId = nil
    }
    
    init(id: UUID, name: String, contactType: String, customContactType: String, imageName: String, lastMessage: Date, countMessages: Int, phone: String, birthday: Date?,
         reminder: Bool, reminderDate: Date?, reminderRepeat: String, reminderBirthday: Bool, reminderBeforeBirthday: Bool, reminderCountDayBeforeBirthday: Int,
         connectChannels: [ConnectChannel], systemContactId: String? = nil) {
        self.id = id
        self.name = name
        self.contactType = contactType
        self.customContactType = customContactType
        self.imageName = imageName
        self.lastMessage = lastMessage
        self.countMessages = countMessages
        self.phone = phone
        self.birthday = birthday
        self.reminder = reminder
        self.reminderDate = reminderDate ?? Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        self.reminderRepeat = reminderRepeat == "" ? "Monthly": reminderRepeat
        self.reminderBirthday = reminderBirthday
        self.reminderBeforeBirthday = reminderBeforeBirthday
        self.reminderCountDayBeforeBirthday = reminderCountDayBeforeBirthday
        self.connectChannels = connectChannels
        self.isNotSaved = false
        self.systemContactId = systemContactId
    }
}
