//
//  ContactDetailViewModel.swift
//  KITouch
//
//  Created by Роман Вертячих on 02.06.2025.
//

import Combine

final class ContactDetailViewModel: ObservableObject {
    var networks = [NetworkResponse]() {
        didSet {
            isShowingNetworkListView = true
        }
    }
    
    @Published var isShowingNetworkListView = false
}
