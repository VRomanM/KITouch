//
//  ContactDetailView.swift
//  KITouch
//
//  Created by Роман Вертячих on 30.05.2025.
//

import SwiftUI

struct ContactDetailView: View {
    let contact: ContactResponse
    @Binding var isShowingDetailView: Bool
    let columns: [GridItem] = [GridItem(.flexible(),alignment: .leading),
                               GridItem(.flexible(), alignment: .leading)]
    @StateObject var viewModel = ContactDetailViewModel()
    
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
                Image(systemName: contact.imageName)
                    .resizable()
                    .frame(width: 250, height: 250)
                    .foregroundStyle(.tint)
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(5)
                    .padding()
                
                Text(contact.name)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                Text(contact.contactType)
                    .font(.title2)
                    .foregroundColor(.gray)
                Text("Общались \(contact.lastMessage, format: .dateTime.day().month().year())")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading) {
                    Text("Phone")
                        .font(.callout)
                        .foregroundColor(.gray)
                    Text(contact.phone)
                        .font(.body)
                    Divider()
                    Text("Birthdate")
                        .font(.callout)
                        .foregroundColor(.gray)
                    Text(contact.birthday, format: .dateTime.day().month().year())
                        .font(.body)
                    Divider()
                    HStack {
                        Text("Networks")
                            .font(.callout)
                            .foregroundColor(.gray)
                        Spacer()
                        Button {
                            viewModel.networks = MocData.networks
                        } label: {
                            Image(systemName: "pencil")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                    }
                    
                    LazyVGrid(columns: columns) {
                        ForEach(contact.networks) { network in
                            NetworkView(network: network)
                        }
                    }
                }
                .padding(25)
                .fullScreenCover(isPresented: $viewModel.isShowingNetworkListView) {
                    
                } content: {
                    NetworkListView(viewModel: viewModel)
                }
                Spacer()
            }
        }
    }
}

struct NetworkView: View {
    let network: NetworkResponse
    
    var body: some View {
        HStack {
            Image(network.network.icon)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 30, height: 30)
            Text(network.login)
                .font(.footnote)
                .fontWeight(.light)
        }
    }
}

#Preview {
    ContactDetailView(contact: MocData.sampleContact, isShowingDetailView: .constant(true))
}
