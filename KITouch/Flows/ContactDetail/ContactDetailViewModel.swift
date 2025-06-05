//
//  ContactDetailViewModel.swift
//  KITouch
//
//  Created by Роман Вертячих on 02.06.2025.
//

import Combine

final class ContactDetailViewModel: ObservableObject {
    
    //MARK: - Properties
    
    var contact: Contact
    
    @Published var isShowingConnectChannelsListView = false
    
    //MARK: - Constructions
    
    init(contact: Contact) {
        self.contact = contact
    }
    
    //MARK: - Function
      
    func saveContactDetail() {
        contact.connectChannels.removeAll()
    }
}
