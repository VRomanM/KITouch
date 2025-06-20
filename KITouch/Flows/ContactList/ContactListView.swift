//
//  ContactListView.swift
//  KiTouch
//
//  Created by Роман Вертячих on 28.05.2025.
//

import SwiftUI

struct ContactListView: View {
    @StateObject var viewModel = ContactListViewModel()
    @State private var showNew = false
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                VStack(spacing: 0) {
                    HStack {
                        TextField("Search", text: $viewModel.searchQuery)
                            .padding(8)
                            .background(.mainBackground)
                            .cornerRadius(8)

                        if !viewModel.searchQuery.isEmpty {
                            Button(action: {
                                viewModel.searchQuery = ""
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }) {
                                Text("Cancel")
                                    .foregroundColor(.white)
                                    .padding(.trailing, 10)
                            }
                        }
                    }
                    .padding(10)
                    .background(.blue)

                    List {
                        ForEach(viewModel.filteredContacts) { contact in
                            NavigationLink(value: contact) {
                                ContactView(contact: contact)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .navigationBarTitleDisplayMode(.inline)
                    .listStyle(.insetGrouped)
                    .listRowSpacing(10)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                showSettings = true
                            }) {
                                Image(systemName: "line.horizontal.3")
                                    .foregroundColor(.white)
                            }
                        }

                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                showNew = true
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
            .navigationDestination(for: Contact.self) { contact in
                ContactDetailView(contactListViewModel: viewModel,
                                  isShowingDetailView: $viewModel.isShowingDetailView,
                                  contact: contact)
            }
            .navigationDestination(isPresented: $showNew) {
                ContactDetailView(contactListViewModel: viewModel,
                                  isShowingDetailView: $viewModel.isShowingDetailView,
                                  contact: Contact())
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
}



#Preview {
    ContactListView()
}

struct BackgroundView: View {
    
    var body: some View {
        Color.mainBackground
        .ignoresSafeArea()
    }
}

struct ContactView: View {
    let contact: Contact
    
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
