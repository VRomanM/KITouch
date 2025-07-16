//
//  NewInteractionViewModel.swift
//  KITouch
//
//  Created by Alexey Chanov on 27.06.2025.
//

import Foundation
import Combine

enum InteractionTypeSelection: String, CaseIterable {
    case call = "Phone Call"
    case meeting = "Meeting"
    case message = "Message"
    case socialMedia = "Social Media"
    
    var interactionType: InteractionType {
        switch self {
        case .call: return .call
        case .meeting: return .meeting
        case .message: return .message
        case .socialMedia: return .socialMedia(.teams, "") // Временное значение, будет обновлено при выборе
        }
    }
    
    init(from interactionType: InteractionType) {
        switch interactionType {
        case .call: self = .call
        case .meeting: self = .meeting
        case .message: self = .message
        case .socialMedia: self = .socialMedia
        }
    }
}

final class InteractionViewModel: ObservableObject {
    @Published var date = Date()
    @Published var notes = ""
    @Published var selectedInteractionType: InteractionType = .call
    @Published var selectedTypeSelection: InteractionTypeSelection = .call
    @Published var availableConnectChannels: [ConnectChannel] = []

    private let contactId: UUID?
    private weak var contactDetailViewModel: ContactDetailViewModel?
    private let coreDataManager = CoreDataManager.sharedManager
    private var existingInteraction: Interaction?
    
    // Инициализатор для создания нового взаимодействия
    init(contactId: UUID, contactDetailViewModel: ContactDetailViewModel) {
        self.contactId = contactId
        self.contactDetailViewModel = contactDetailViewModel
        self.existingInteraction = nil
        self.availableConnectChannels = contactDetailViewModel.contact.connectChannels
    }
    
    // Инициализатор для редактирования существующего взаимодействия
    init(interaction: Interaction, contactDetailViewModel: ContactDetailViewModel) {
        self.contactId = interaction.contactId
        self.contactDetailViewModel = contactDetailViewModel
        self.existingInteraction = interaction
        self.availableConnectChannels = contactDetailViewModel.contact.connectChannels

        // Предзаполняем поля данными существующего взаимодействия
        self.date = interaction.date
        self.notes = interaction.notes
        self.selectedInteractionType = interaction.type
        self.selectedTypeSelection = InteractionTypeSelection(from: interaction.type)
    }

    var isEditing: Bool {
        return existingInteraction != nil
    }

    func saveInteraction() {
        let finalType: InteractionType
        if selectedTypeSelection == .socialMedia {
            if case .socialMedia(let type, let login) = selectedInteractionType {
                finalType = .socialMedia(type, login)
            } else {
                // Этот случай не должен произойти, но на всякий случай
                finalType = .socialMedia(.teams, "")
            }
        } else {
            finalType = selectedTypeSelection.interactionType
        }
        
        if let existing = existingInteraction {
            // Редактирование: сохраняем тот же ID
            let updatedInteraction = Interaction(
                id: existing.id,
                date: date,
                notes: notes,
                contactId: contactId ?? existing.contactId,
                type: finalType
            )

            coreDataManager.updateInteraction(interaction: updatedInteraction) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.contactDetailViewModel?.updateInteraction(updatedInteraction)
                    case .failure(let error):
                        print("Ошибка обновления: \(error)")
                    }
                }
            }
        } else if let contactId = contactId {
            // Создание нового взаимодействия
            let newInteraction = Interaction(
                date: date,
                notes: notes,
                contactId: contactId,
                type: finalType
            )
            coreDataManager.saveInteraction(interaction: newInteraction) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.contactDetailViewModel?.loadInteractions()
                }
            }
        }
    }
}

