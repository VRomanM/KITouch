//
//  ContactDetailViewModel.swift
//  KITouch
//
//  Created by Роман Вертячих on 02.06.2025.
//

import Combine
import Foundation

final class ContactDetailViewModel: ObservableObject {
    
    enum EditingElement {
        case contactName
        case contactType
        case phone
        case birthday
        case nothing
    }
    
    //MARK: - Private properties
    
    private let notificationManager = NotificationManager.sharedManager
    private var contactListViewModel: ContactListViewModel?
    private let coreDataManager = CoreDataManager.sharedManager
    
    //MARK: - Properties
    
    let phonePattern = "+X (XXX) XXX-XX-XX"
    var isPhoneNumberValid: Bool {
        let digits = contact.phone.filter { $0.isNumber }
        return digits.count == 11 // Для российских номеров
    }
    var contact: Contact
    var unwrapBirthday: Date {
        didSet {
            contact.birthday = unwrapBirthday
        }
    }
    
    @Published var isShowingConnectChannelsListView = false
    @Published var editingElement: EditingElement = .nothing
    @Published var isShowingNewInteractionView = false
    @Published var interactions: [Interaction] = []

    //MARK: - Constructions
    
    init(contactListViewModel: ContactListViewModel?, contact: Contact) {
        self.contact = contact
        self.unwrapBirthday = contact.birthday ?? Date.now
        self.contactListViewModel = contactListViewModel
        loadInteractions()
    }
    
    //MARK: - Function
      
    func saveContactDetail() {
        // Сохраняем в CoreData
        if contact.contactType != ContactType.other.rawValue {
            contact.customContactType = ""
        }
        coreDataManager.saveContact(contact: contact) { _ in }
        notificationManager.scheduleBirthdayNotification(for: contact)
        contactListViewModel?.loadData()
    }
    
    func formatPhoneNumber(_ newValue: String) {
        let cleanNumber = newValue.filter { $0.isNumber }
        var result = ""
        var index = cleanNumber.startIndex
        var previousChar = ""
        
        for patternChar in phonePattern where index < cleanNumber.endIndex {
            if patternChar == "X" {
                if previousChar == "+" && cleanNumber[index] == "8" {
                    result.append("7")
                } else {
                    result.append(cleanNumber[index])
                }
                previousChar = ""
                index = cleanNumber.index(after: index)
            } else if result.isEmpty && patternChar == "+" {
                result.append("+")
                previousChar = "+"
            } else if !result.isEmpty {
                result.append(patternChar)
            }
        }
        contact.phone = result
    }

    func loadInteractions() {
        coreDataManager.fetchInteractions(for: contact.id) { [weak self] interactions in
            DispatchQueue.main.async {
                self?.interactions = interactions
            }
        }
    }
}


