//
//  ContactDetailViewModel.swift
//  KITouch
//
//  Created by Роман Вертячих on 02.06.2025.
//
//
// ContactDetailViewModel.swift
// KITouch
//
// Created by Роман Вертячих on 02.06.2025.
//

import SwiftUI

final class ContactDetailViewModel: ObservableObject {
    
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
    
    // Данные
    @Published var contact: Contact
    @Published var interactions: [Interaction] = []
    @Published var selectedInteraction: Interaction?
    
    // Навигация
    @Published var navigationPath = NavigationPath()
    @Published var isShowingInteractionListView = false
    @Published var isShowingConnectChannelsListView = false
    @Published var isEmojiPickerPresented = false
    @Published var isShowingNewInteractionView = false
    @Published var isShowingEditInteractionView = false
    
    //MARK: - Constructions
    init(contactListViewModel: ContactListViewModel?, contact: Contact) {
        self.contact = contact
        self.contactListViewModel = contactListViewModel
        loadInteractions()
    }
    
    //MARK: - Functions
    func saveContactDetail() {
        // Сохраняем в CoreData
        if contact.contactType != ContactType.other.rawValue {
            contact.customContactType = ""
        }
        coreDataManager.saveContact(contact: contact) { _ in }
        
        // Настраиваем уведомления
        notificationManager.setContactScheduleNotifications(for: contact)
        
        // Обновляем данные из CoreData
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

    func updateInteraction(_ updatedInteraction: Interaction) {
        // Обновляем в локальном массиве
        if let index = interactions.firstIndex(where: { $0.id == updatedInteraction.id }) {
            interactions[index] = updatedInteraction
        }

        // Сохраняем в CoreData
        coreDataManager.updateInteraction(interaction: updatedInteraction) { [weak self] result in
            switch result {
            case .success:
                print("Interaction updated successfully in CoreData")
            case .failure(let error):
                print("Failed to update interaction in CoreData: \(error)")
                // Перезагружаем данные в случае ошибки
                DispatchQueue.main.async {
                    self?.loadInteractions()
                }
            }
        }
    }

    func deleteInteraction(_ interaction: Interaction) {
        // Удаляем из локального массива
        interactions.removeAll { $0.id == interaction.id }

        // Удаляем из CoreData
        coreDataManager.deleteInteraction(interaction) { [weak self] result in
            switch result {
            case .success:
                print("Interaction deleted successfully from CoreData")
            case .failure(let error):
                print("Failed to delete interaction from CoreData: \(error)")
                // В случае ошибки перезагружаем данные
                DispatchQueue.main.async {
                    self?.loadInteractions()
                }
            }
        }
    }
}
