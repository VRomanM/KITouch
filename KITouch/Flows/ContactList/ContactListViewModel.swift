//
//  ContactListViewModel.swift
//  KITouch
//
//  Created by Роман Вертячих on 30.05.2025.
//

import Combine

final class ContactListViewModel: ObservableObject {
    
    var selectedContact: Contact? {
        didSet {
            isShowingDetailView = true
        }
    }
    
    var connectChannels = [ConnectChannel]() {
        didSet {
            isShowingNetworkListView = true
        }
    }

    @Published var isShowingDetailView = false
    @Published var isShowingNetworkListView = false
    @Published var searchQuery = ""

    var filteredContacts: [Contact] {
        if searchQuery.isEmpty {
            return MocData.contacts
        } else {
            return MocData.contacts.filter { contact in
                contact.name.localizedCaseInsensitiveContains(searchQuery)
            }
        }
    }
}
