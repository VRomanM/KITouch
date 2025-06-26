//
//  NewInteractionViewModel.swift
//  KITouch
//
//  Created by Alexey Chanov on 27.06.2025.
//

import Foundation
import Combine

final class NewInteractionViewModel: ObservableObject {
    @Published var date = Date()
    @Published var notes = ""

    private let contactId: UUID
    private weak var contactDetailViewModel: ContactDetailViewModel?
    private let coreDataManager = CoreDataManager.sharedManager

    init(contactId: UUID, contactDetailViewModel: ContactDetailViewModel) {
        self.contactId = contactId
        self.contactDetailViewModel = contactDetailViewModel
    }

    func saveInteraction() {
        let interaction = Interaction(date: date, notes: notes, contactId: contactId)
        coreDataManager.saveInteraction(interaction: interaction) { [weak self] _ in
            DispatchQueue.main.async {
                self?.contactDetailViewModel?.loadInteractions()
            }
        }
    }
}
