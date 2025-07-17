//
//  Interaction.swift
//  KITouch
//
//  Created by Alexey Chanov on 27.06.2025.
//

import Foundation
import SwiftUI

enum InteractionType: Hashable {
    case call
    case meeting
    case message
    case socialMedia(SocialMediaType, String) // Updated to include login
    
    var icon: String {
        switch self {
        case .call:
            return "phone.fill"
        case .meeting:
            return "person.2.fill"
        case .message:
            return "message.fill"
        case .socialMedia(let type, _):
            return type.icon
        }
    }
    
    var title: String {
        switch self {
        case .call:
            return "Phone Call"
        case .meeting:
            return "Meeting"
        case .message:
            return "Message"
        case .socialMedia(let type, let login):
            return "\(type.rawValue) (\(login))"
        }
    }
    
    var color: Color {
        switch self {
        case .call:
            return .green
        case .meeting:
            return .blue
        case .message:
            return .orange
        case .socialMedia:
            return .gray
        }
    }
}

struct Interaction: Hashable, Identifiable {
    var id = UUID()
    var date: Date
    var notes: String
    var contactId: UUID
    var type: InteractionType
    
    init(date: Date = Date(), notes: String = "", contactId: UUID, type: InteractionType = .call) {
        self.date = date
        self.notes = notes
        self.contactId = contactId
        self.type = type
    }
    
    init(id: UUID, date: Date, notes: String, contactId: UUID, type: InteractionType = .call) {
        self.id = id
        self.date = date
        self.notes = notes
        self.contactId = contactId
        self.type = type
    }
}

