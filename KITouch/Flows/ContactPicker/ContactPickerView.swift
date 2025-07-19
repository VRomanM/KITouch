//
//  ContactPickerView.swift
//  KITouch
//
//  Created by Роман Вертячих on 30.06.2025.
//

//import ContactsUI
import SwiftUI

struct ContactPickerView: View {
    var onSelectContact: (Contact) -> Void

    @StateObject private var viewModel = ContactPickerViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Поисковая строка
            HStack {
                TextField("Search contacts", text: $viewModel.searchQuery)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                if !viewModel.searchQuery.isEmpty {
                    Button(action: {
                        viewModel.clearSearch()
                    }) {
                        Text("Cancel")
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            List {
                ForEach(viewModel.filteredContacts) { contact in
                    Button {
                        viewModel.handleContactSelection(contact) { duplicateContact in
                            if let duplicate = duplicateContact {
                                // Показать алерт через ViewModel
                            } else {
                                onSelectContact(contact)
                            }
                        }
                    } label: {
                        HStack {
                            Text(contact.name)
                                .foregroundColor(.primary)
                            Spacer()
                            if !contact.phone.isEmpty {
                                Text(contact.phone)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Contacts")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadContacts()
        }
        .alert("Contact already exists", isPresented: $viewModel.showDuplicateAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Open") {
                if let duplicateContact = viewModel.duplicateContact {
                    onSelectContact(duplicateContact)
                }
            }
        } message: {
            Text("This contact has already been added to your list")
        }
    }
}
