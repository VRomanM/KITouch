//
//  ContactListView.swift
//  KiTouch
//
//  Created by Роман Вертячих on 28.05.2025.
//

import SwiftUI

struct ContactListView: View {
    @StateObject var viewModel = ContactListViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(MocData.contacts) { contact in
                    Section {
                        ContactView(contact: contact)
                            .onTapGesture {
                                viewModel.selectedContact = contact
                            }
                    }
                }
                .listStyle(.grouped)
                .listSectionSpacing(.compact)
            }
            .navigationTitle("Contacts")
            .fullScreenCover(isPresented: $viewModel.isShowingDetailView) {
                ContactDetailView(contact: viewModel.selectedContact ?? MocData.sampleContact, isShowingDetailView: $viewModel.isShowingDetailView)
            }
        }
    }
}

#Preview {
    ContactListView()
}

struct ContactView: View {
    let contact: ContactResponse
    
    var body: some View {
        HStack {
            Image(systemName: contact.imageName)
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundStyle(.tint)
                .aspectRatio(contentMode: .fit)
            VStack(alignment: .leading) {
                Spacer()
                Text(contact.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(contact.contactType)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                Spacer()
                HStack {
                    Text("Talked \(contact.lastMessage, format: .dateTime.day().month().year())")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                    Spacer()
                    Text("\(contact.countMessages)")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }
                Spacer()
            }
        }
    }
}
