//
//  ContactListViewModel.swift
//  KITouch
//
//  Created by Роман Вертячих on 30.05.2025.
//

import SwiftUI

final class ContactListViewModel: ObservableObject {
    
    var selectedContact: ContactResponse? {
        didSet {
            isShowingDetailView = true
        }
    }
    
    @Published var isShowingDetailView = false
}
