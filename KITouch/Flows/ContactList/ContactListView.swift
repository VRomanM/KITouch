//
//  ContactListView.swift
//  KiTouch
//
//  Created by Роман Вертячих on 28.05.2025.
//

import SwiftUI

fileprivate enum ContactRoute: Hashable {
    case detail(contact: Contact)
    case settings
    case newContact
}

struct ContactListView: View {
    @StateObject var viewModel = ContactListViewModel()
    
    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
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
                        ForEach(viewModel.filteredContacts()) { contact in
                            ContactView(contact: contact)
                                .onTapGesture {
                                    viewModel.navigationPath.append(ContactRoute.detail(contact: contact))
                                }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .navigationBarTitleDisplayMode(.inline)
                    .listStyle(.insetGrouped)
                    .listRowSpacing(10)
                    .navigationDestination(for: ContactRoute.self) { route in
                                    switch route {
                                    case .detail(let contact):
                                        ContactDetailView(contactListViewModel: viewModel, contact: contact)
                                    case .settings:
                                        SettingsView()
                                    case .newContact:
                                        ContactDetailView(contactListViewModel: viewModel, contact: Contact())
                                    }
                                }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                viewModel.navigationPath.append(ContactRoute.settings)
                            }) {
                                Image(systemName: "line.horizontal.3")
                                    .foregroundColor(.white)
                            }
                        }

                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                viewModel.navigationPath.append(ContactRoute.newContact)
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
            .onNotification { notification in
                DispatchQueue.main.async {
                    // Переход осуществялем через главную очередь, т.к. если в момент перехода с Пуша приложение было закрыто происходит инициализация
                    // экземпляра класса viewModel и первичная загрузка контактов из CoreData, так же в главном потоке
                    if let contactId = notification.notification.request.content.userInfo["contactId"] as? String,
                       let contact = viewModel.findContact(by: contactId) {
                        viewModel.navigationPath.append(ContactRoute.detail(contact: contact))
                    }
                }
            }
            .onOpenURL { url in
                // Обработка deep links
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
            Text(contact.imageName)
                .font(.system(size: 40))
                .padding()
            VStack(alignment: .leading) {
                Spacer()
                Text(contact.name.localized())
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(contact.contactType.localized())
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
