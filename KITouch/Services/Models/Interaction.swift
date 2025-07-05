//
//  Interaction.swift
//  KITouch
//
//  Created by Alexey Chanov on 27.06.2025.
//

import Foundation

enum TypeInteraction: String {
    case call = "1"
    case meeting = "2"
    case message = "3"
    case email = "4"
}

struct Interaction: Hashable, Identifiable {
    
    var id = UUID()
    var date: Date
    var notes: String
    var contactId: UUID
    var type: TypeInteraction = .call

    init(date: Date = Date(), notes: String = "", contactId: UUID) {
        self.date = date
        self.notes = notes
        self.contactId = contactId
    }

    init(id: UUID, date: Date, notes: String, contactId: UUID) {
        self.id = id
        self.date = date
        self.notes = notes
        self.contactId = contactId
    }
}

