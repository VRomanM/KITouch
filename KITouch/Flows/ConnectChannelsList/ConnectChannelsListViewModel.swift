//
//  ConnectChannelsListViewModel.swift
//  KITouch
//
//  Created by Роман Вертячих on 05.06.2025.
//

import Combine
import Foundation

final class ConnectChannelsListViewModel: ObservableObject {
    
    //MARK: - Private properties
    
    private  var contactDetalViewModel: ContactDetailViewModel?
    
    //MARK: - Properties
    
    @Published var connectChannels: [ConnectChannel]
    
    //MARK: - Function
    
    func addConnectChannel() -> ConnectChannel {
        let newConnectChannel = ConnectChannel(socialMediaType: .email, login: "")
        connectChannels.append(newConnectChannel)
        return newConnectChannel
    }
    
    func saveConnectChannels() {
        guard let viewModel = contactDetalViewModel else { return }
        viewModel.contact.connectChannels = connectChannels
        viewModel.isShowingConnectChannelsListView = false
    }
    
    func closeView() {
        guard let viewModel = contactDetalViewModel else { return }
        // Сначала закрываем view, потом обновляем данные
        viewModel.isShowingConnectChannelsListView = false
        // Обновляем данные с задержкой чтобы избежать конфликта с UI
        DispatchQueue.main.async {
            self.connectChannels = viewModel.contact.connectChannels
        }
    }
    
    func deleteChannel(_ channel: ConnectChannel) {
        connectChannels.removeAll { $0 == channel }
    }
    
    init(contactDetalViewModel: ContactDetailViewModel?) {
        self.contactDetalViewModel = contactDetalViewModel
        self.connectChannels = contactDetalViewModel?.contact.connectChannels ?? [ConnectChannel]()
    }
}
