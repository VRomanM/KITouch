//
//  ContactListView.swift
//  KiTouch
//
//  Created by Роман Вертячих on 28.05.2025.
//

import SwiftUI

import SwiftUI

struct ContactListView: View {
    @StateObject var viewModel = ContactListViewModel()

    // Состояние для поискового запроса
    @State private var searchQuery = ""

    let date: Date = {
        var components = DateComponents()
        components.day = 7
        components.month = 10
        components.year = 2024
        return Calendar.current.date(from: components) ?? Date()
    }()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Поисковое поле
                HStack {
                    TextField("Поиск", text: $searchQuery)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)

                    Spacer()
                }
                .padding(10)

                // Список контактов с фильтрацией
                List {
                    ForEach(filteredContacts) { contact in
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
                .navigationTitle("Контакты")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {}) {
                            Image(systemName: "line.horizontal.3")
                                .foregroundColor(.white)
                        }
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {}) {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                        }
                    }
                }
            }.background(Color(.blue))
                .gesture(
                    TapGesture()
                        .onEnded { _ in
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                )

            // Поддержка детального экрана
            .sheet(isPresented: $viewModel.isShowingDetailView) {
                ContactDetailView(contact: viewModel.selectedContact ?? MocData.sampleContact, isShowingDetailView: $viewModel.isShowingDetailView)
            }
        }
    }

    // Фильтрация контактов по поисковому запросу
    private var filteredContacts: [ContactResponse] {
        if searchQuery.isEmpty {
            return MocData.contacts
        } else {
            return MocData.contacts.filter { contact in
                contact.name.localizedCaseInsensitiveContains(searchQuery)
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
                    Text("Общались \(contact.lastMessage, format: .dateTime.day().month().year())")
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
