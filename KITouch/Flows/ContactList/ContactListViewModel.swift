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
            updateSelectedContacts()
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
    @Published var searchQuery = "" {
        didSet {
            filteredContacts = filterData()
        }
    }

    var filteredContacts = [Contact]()
    var contacts = [Contact]()
    
    //MARK: - Constructions
    
    init() {
        let contacts = loadData()
        self.contacts = contacts
        self.filteredContacts = contacts
    }
    
    //MARK: - Function
    
    private func loadData() -> [Contact] {
        MocData.contacts
    }
    
    private func filterData() -> [Contact] {
        if searchQuery.isEmpty {
            return contacts
        } else {
            return contacts.filter { contact in
                contact.name.localizedCaseInsensitiveContains(searchQuery)
            }
        }
    }
    
    private func updateSelectedContacts() {
        guard let updatedContact = selectedContact else { return }
        
        if let index = filteredContacts.firstIndex(where: { $0.id == updatedContact.id }) {
            filteredContacts[index] = updatedContact
        } else {
            filteredContacts.append(updatedContact)
        }
        
        if let index = contacts.firstIndex(where: { $0.id == updatedContact.id }) {
            contacts[index] = updatedContact
        } else {
            contacts.append(updatedContact)
        }
    }
}
