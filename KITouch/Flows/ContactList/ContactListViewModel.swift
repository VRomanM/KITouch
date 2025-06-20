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
        loadData()
    }
    
    //MARK: - Private function
        
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
    
    private func retrieveContactsFromCoreData() {
        
        isLoading = true
        
        coreDataManager.retrieveContacts { [weak self] success, contacts in
            DispatchQueue.main.async {
                if let contacts = contacts {
                    let mappedContacts: [Contact] = contacts.compactMap { contact in
                        
                        // Преобразование ConnectChannelEntity в ConnectChannel
                        let connectChannels: [ConnectChannel] = (contact.connectChannelEntity as? Set<ConnectChannelEntity> ?? [])
                            .compactMap { channelEntity in
                                let socialMediaType = SocialMediaType(rawValue: channelEntity.socialMediaType) ?? .email
                                    
                                
                                return ConnectChannel(
                                    id: channelEntity.id,
                                    socialMediaType: socialMediaType,
                                    login: channelEntity.login
                                )
                            }
                        
                        return Contact(
                            id: contact.id,
                            name: contact.name,
                            contactType: contact.contactType,
                            imageName: contact.imageName,
                            lastMessage: contact.lastMessage,
                            countMessages: Int(contact.countMessages),
                            phone: contact.phone,
                            birthday: contact.birthday,
                            connectChannels: connectChannels
                        )
                    }
                    
                    self?.contacts = mappedContacts
                    self?.filteredContacts = mappedContacts
                }
                self?.isLoading = false
            }
        }
    }
    
    //MARK: - Function
    
    func loadData() {
        retrieveContactsFromCoreData()
        //MocData.contacts
    }
}
