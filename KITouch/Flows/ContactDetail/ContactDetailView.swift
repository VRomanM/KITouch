//
//  ContactDetailView.swift
//  KITouch
//
//  Created by Роман Вертячих on 30.05.2025.
//

import SwiftUI

struct ContactDetailView: View {
    @Binding var isShowingDetailView: Bool
    let columns: [GridItem] = [GridItem(.flexible(),alignment: .leading),
                               GridItem(.flexible(), alignment: .leading)]
    @StateObject var viewModel: ContactDetailViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Spacer()
                    Button {
                        isShowingDetailView = false
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color(.label))
                            .imageScale(.large)
                            .frame(width: 44, height: 44)
                    }
                }
                Image(systemName: viewModel.contact.imageName)
                    .resizable()
                    .frame(width: 250, height: 250)
                    .foregroundStyle(.tint)
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(5)
                    .padding()
                
                Text(viewModel.contact.name)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                Text(viewModel.contact.contactType)
                    .font(.title2)
                    .foregroundColor(.gray)
                Text("Talked \(viewModel.contact.lastMessage, format: .dateTime.day().month().year())")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading) {
                    Text("Phone")
                        .font(.callout)
                        .foregroundColor(.gray)
                    Text(viewModel.contact.phone)
                        .font(.body)
                    Divider()
                    Text("Birthdate")
                        .font(.callout)
                        .foregroundColor(.gray)
                    Text(viewModel.contact.birthday, format: .dateTime.day().month().year())
                        .font(.body)
                    Divider()
                    HStack {
                        Text("Soc. media")
                            .font(.callout)
                            .foregroundColor(.gray)
                        Spacer()
                        Button {
                            viewModel.isShowingConnectChannelsListView = true
                        } label: {
                            Image(systemName: "pencil")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                    }
                    LazyVGrid(columns: columns) {
                        ForEach(viewModel.contact.connectChannels) { connectChannel in
                            NetworkView(connectChannel: connectChannel)
                        }
                    }
                }
                .padding(25)
                .fullScreenCover(isPresented: $viewModel.isShowingConnectChannelsListView) {}
                content: {
                    ConnectChannelsListView(viewModel: ConnectChannelsListViewModel(contactDetalViewModel: viewModel))
                }
                Button(action: {
                    viewModel.saveContactDetail()
                    isShowingDetailView = false
                }) {
                    KITButton(text: "Save")
                }
                Spacer()
            }
        }
    }
    
    init(contact: Contact, isShowingDetailView: Binding<Bool>) {
        _isShowingDetailView = isShowingDetailView
        _viewModel = StateObject(wrappedValue: ContactDetailViewModel(contact: contact))
    }
}

struct NetworkView: View {
    let connectChannel: ConnectChannel
    
    var body: some View {
        HStack {
            Image(connectChannel.socialMediaType.icon)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 30, height: 30)
            Text(connectChannel.login)
                .font(.footnote)
                .fontWeight(.light)
        }
    }
}

#Preview {
    ContactDetailView(contact: MocData.sampleContact, isShowingDetailView: .constant(true))
}
