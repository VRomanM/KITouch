//
//  ContactListViewModel.swift
//  KITouch
//
//  Created by Роман Вертячих on 30.05.2025.
//

import SwiftUI

final class ContactListViewModel: ObservableObject {
    
    //MARK: - Private properties
    
    private let coreDataManager = CoreDataManager.sharedManager
    
    //MARK: - Properties
    
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
    @Published var isLoading = false
    @Published var error: Error?
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
    
    //MARK: - Private function
    
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
    
    //MARK: - Function
    
    func retrieveContactsFromCoreData() {
        isLoading = true
        error = nil
        
        coreDataManager.retrieveContacts { [weak self] success, contacts in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let contacts = contacts {
                    self?.contacts.append(contentsOf: contacts.compactMap({ contact in
                        
                        Contact(id: contact.id,
                                name: contact.name,
                                contactType: contact.contactType,
                                imageName: contact.imageName,
                                lastMessage: contact.lastMessage,
                                countMessages: contact.countMessages,
                                phone: contact.phone,
                                birthday: contact.birthday,
                                connectChannels: connectChannels)
                    }))
                    
                    
                    for contact in contacts {
//                        if let contact = contact,
                        contacts.append(ContactInfoData.transformToContact(contactEntity: contact))
                           let contactFromStorage = ContactInfoData.transformToContact(contactEntity: contact) {
                            self.setupProfile(profileFromStorage)
//                        }
                    }
                }
                if success {
                    self?.contacts.append(contact)
                } else {
                    self?.error = error
                }
            }
        }
    }
}
