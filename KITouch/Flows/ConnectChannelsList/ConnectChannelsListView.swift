//
//  ConnectChannelsListView.swift
//  KITouch
//
//  Created by Роман Вертячих on 02.06.2025.
//

import SwiftUI

struct ConnectChannelsListView: View {
    @StateObject var viewModel: ConnectChannelsListViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    ForEach($viewModel.connectChannels) { $connectChannel in
                        HStack {
                            TextField(text: $connectChannel.login, label: { Text("Enter login") })
                                .padding()
                            Picker(selection: $connectChannel.socialMediaType, label:
                                    Label(title: {}, icon: {
                                HStack {
                                    Spacer()
                                    Image(connectChannel.socialMediaType.icon)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                    Spacer()
                                }
                            })) {
                                ForEach(SocialMediaType.allCases) { socialMediaType in
                                    Text(socialMediaType.rawValue)
                                        .tag(socialMediaType)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                    .onDelete { indexSet in
                        viewModel.connectChannels.remove(atOffsets: indexSet)
                    }
                }
                
                Button {
                    viewModel.saveConnectChannels()
                } label: {
                    KITButton(text: "Save")
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        viewModel.closeView()
                    }) {
                        Text("Cancel")
                            .foregroundColor(.white)
                            .padding(.trailing, 10)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.addConnectChannel()
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

#Preview {
    ConnectChannelsListView(viewModel: ConnectChannelsListViewModel(contactDetalViewModel: ContactDetailViewModel(contact: MocData.sampleContact)))
}
