//
//  ConnectChannelsListViewModel.swift
//  KITouch
//
//  Created by Роман Вертячих on 05.06.2025.
//

import Combine

final class ConnectChannelsListViewModel: ObservableObject {
    
    //MARK: - Private properties
    
    private  var contactDetalViewModel: ContactDetailViewModel?
    
    //MARK: - Properties
    
    @Published var connectChannels: [ConnectChannel]
    @Published var refreshConnectChannelListView = false
    
    //MARK: - Function
    
    func addConnectChannel() {
        let newConnectChannel = ConnectChannel(socialMediaType: .email, login: "")
        connectChannels.append(newConnectChannel)
        refreshConnectChannelListView.toggle()
    }
    
    func saveConnectChannels() {
        guard let viewModel = contactDetalViewModel else { return }
        viewModel.contact.connectChannels = connectChannels
        viewModel.isShowingConnectChannelsListView = false
    }
    
    func closeView() {
        guard let viewModel = contactDetalViewModel else { return }
        connectChannels = viewModel.contact.connectChannels
        viewModel.isShowingConnectChannelsListView = false
    }
    
    func deleteChannel(_ channel: ConnectChannel) {
        connectChannels.removeAll { $0 == channel }
    }
    
    init(contactDetalViewModel: ContactDetailViewModel?) {
        self.contactDetalViewModel = contactDetalViewModel
        self.connectChannels = contactDetalViewModel?.contact.connectChannels ?? [ConnectChannel]()
        self.refreshConnectChannelListView = refreshConnectChannelListView
    }
}
