//
//  ContactListViewModel.swift
//  KITouch
//
//  Created by Роман Вертячих on 30.05.2025.
//

import SwiftUI

final class ContactListViewModel: ObservableObject {
    
    var selectedContact: ContactResponse? {
        didSet {
            isShowingDetailView = true
        }
    }

    @Published var isShowingDetailView = false
    // Состояние для поискового запроса
    @Published var searchQuery = ""

    // Фильтрация контактов по поисковому запросу
    var filteredContacts: [ContactResponse] {
        if searchQuery.isEmpty {
            return MocData.contacts
        } else {
            return MocData.contacts.filter { contact in
                contact.name.localizedCaseInsensitiveContains(searchQuery)
            }
        }
    }
}
