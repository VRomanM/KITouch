//
//  NewInteractionViewModel.swift
//  KITouch
//
//  Created by Alexey Chanov on 27.06.2025.
//

import Foundation
import Combine

final class InteractionViewModel: ObservableObject {
    @Published var date = Date()
    @Published var notes = ""

    private let contactId: UUID
    private weak var contactDetailViewModel: ContactDetailViewModel?
    private let coreDataManager = CoreDataManager.sharedManager
    private var existingInteraction: Interaction?

    // Инициализатор для создания нового взаимодействия
    init(contactId: UUID, contactDetailViewModel: ContactDetailViewModel) {
        self.contactId = contactId
        self.contactDetailViewModel = contactDetailViewModel
        self.existingInteraction = nil // Явно указываем, что это новое взаимодействие
    }

    // Инициализатор для редактирования существующего взаимодействия
    init(interaction: Interaction, contactDetailViewModel: ContactDetailViewModel) {
        self.contactId = interaction.contactId
        self.contactDetailViewModel = contactDetailViewModel
        self.existingInteraction = interaction

        // Предзаполняем поля данными существующего взаимодействия
        self.date = interaction.date
        self.notes = interaction.notes
    }

    var isEditing: Bool {
        return existingInteraction != nil
    }

    func saveInteraction() {
        if let existing = existingInteraction {
            // Редактирование: сохраняем тот же ID
            let updatedInteraction = Interaction(
                id: existing.id, // Используем существующий ID
                date: date,
                notes: notes,
                contactId: contactId
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
        } else {
            // Создание нового взаимодействия
            let newInteraction = Interaction(date: date, notes: notes, contactId: contactId)
            coreDataManager.saveInteraction(interaction: newInteraction) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.contactDetailViewModel?.loadInteractions()
                }
            }
        }
    }

}

