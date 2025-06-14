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
    private let coreDataManager = CoreDataManager.sharedManager
    
    //MARK: - Properties
    
    let phonePattern = "+X (XXX) XXX-XX-XX"
    var isPhoneNumberValid: Bool {
        let digits = contact.phone.filter { $0.isNumber }
        return digits.count == 11 // Для российских номеров
    }
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
//        contactListViewModel?.selectedContact = contact
               
        // Сохраняем в CoreData
        coreDataManager.saveContact(contact: contact) { success in
            
        }
        
        // Обновляем список контактов
        contactListViewModel?.retrieveContactsFromCoreData()
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
}


