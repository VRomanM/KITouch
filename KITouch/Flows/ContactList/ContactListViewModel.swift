//
//  ContactListViewModel.swift
//  KITouch
//
//  Created by Роман Вертячих on 30.05.2025.
//

import SwiftUI
import ContactsUI

final class ContactListViewModel: ObservableObject {
    
    //MARK: - Private properties
    
    private let coreDataManager = CoreDataManager.sharedManager
    
    //MARK: - Properties
    
    @Published var showNew = false
    @Published var showSettings = false
    
    var connectChannels = [ConnectChannel]() {
        didSet {
            isShowingNetworkListView = true
        }
    }
    @Published var isLoading = false
    @Published var isShowingDetailView = false
    @Published var isShowingNetworkListView = false
    @Published var searchQuery = ""
    @Published var navigationPath = NavigationPath()
    
    var contacts = [Contact]()
    
    //MARK: - Constructions
    
    init() {
        loadData()
    }
    
    //MARK: - Private function
    
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
                            customContactType: contact.customContactType,
                            imageName: contact.imageName,
                            lastMessage: contact.lastMessage,
                            countMessages: Int(contact.countMessages),
                            phone: contact.phone,
                            birthday: contact.birthday,
                            connectChannels: connectChannels
                        )
                    }
                    
                    self?.contacts = mappedContacts
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
    
    func findContact(by id: String?) -> Contact? {
        return contacts.first { $0.idString == id }
    }
    
    func deleteContacts(contact: Contact){
        // Удаляем из локального массива
        contacts.removeAll { $0.id == contact.id }

        // Удаляем из CoreData
        coreDataManager.deleteContact(contact) { [weak self] result in
            switch result {
            case .success:
                print("Contact deleted successfully from CoreData")
            case .failure(let error):
                print("Failed to delete contact from CoreData: \(error)")
                // В случае ошибки перезагружаем данные
                DispatchQueue.main.async {
                    self?.loadData()
                }
            }
        }
    }
    
    func filteredContacts() -> [Contact] {
        if searchQuery.isEmpty {
            return contacts
        } else {
            return contacts.filter { contact in
                contact.name.localizedCaseInsensitiveContains(searchQuery)
            }
        }
    }
}

