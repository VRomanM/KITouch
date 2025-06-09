//
//  ContactDetailViewModel.swift
//  KITouch
//
//  Created by Роман Вертячих on 02.06.2025.
//

import Combine

final class ContactDetailViewModel: ObservableObject {
    
    enum EditingElement {
        case contactName
        case contactType
        case phone
        case birthday
        case nothing
    }
    
    //MARK: - Private properties
    
    private var contactListViewModel: ContactListViewModel?
    
    //MARK: - Properties

    var contact: Contact
    @Published var isShowingConnectChannelsListView = false
    @Published var editingElement: EditingElement = .nothing
    
    //MARK: - Constructions
    
    init(contactListViewModel: ContactListViewModel?, contact: Contact) {
        self.contact = contact
        self.contactListViewModel = contactListViewModel
    }
    
    //MARK: - Function
      
    func saveContactDetail() {
        contactListViewModel?.selectedContact = contact
    }
}


