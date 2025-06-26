//
//  Interaction.swift
//  KITouch
//
//  Created by Alexey Chanov on 27.06.2025.
//

import Foundation

struct Interaction: Hashable, Identifiable {
    var id = UUID()
    var date: Date
    var notes: String
    var contactId: UUID

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

