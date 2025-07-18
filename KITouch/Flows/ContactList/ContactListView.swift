//
//  ContactListView.swift
//  KiTouch
//
//  Created by Роман Вертячих on 28.05.2025.
//

import SwiftUI

enum ContactRoute: Hashable {
    case detail(contact: Contact, isShowNewInteraction: Bool = false)
    case settings
    case newContact
    case fromContacts
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

                    ZStack {
                        List {
                            ForEach(viewModel.filteredContacts()) { contact in
                                ContactView(contact: contact, onAddAction: {
                                    viewModel.navigationPath.append(ContactRoute.detail(contact: contact, isShowNewInteraction: true))
                                })
                                    .onTapGesture {
                                        viewModel.navigationPath.append(ContactRoute.detail(contact: contact))
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            viewModel.deleteContacts(contact: contact)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .listStyle(.insetGrouped)
                        .listRowSpacing(10)

                        // Пустое состояние
                        if viewModel.filteredContacts().isEmpty {
                            VStack(spacing: 20) {
                                Text("Add your first contact")
                                    .font(.title2)
                                    .foregroundColor(.secondary)

                                Menu {
                                    Button(action: {
                                        viewModel.navigationPath.append(ContactRoute.newContact)
                                    }) {
                                        Label("New", systemImage: "person.fill.badge.plus")
                                    }

                                    Button(action: {
                                        viewModel.checkContactsPermission()
                                    }) {
                                        Label("From contacts", systemImage: "person.crop.circle.fill.badge.plus")
                                    }
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.title)
                                        .foregroundColor(.white)
                                        .frame(width: 60, height: 60)
                                        .background(Color.blue)
                                        .clipShape(Circle())
                                }
                            }
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationDestination(for: ContactRoute.self) { route in
                        switch route {
                        case .detail(let contact, let isShowingNewInteractionView):
                            ContactDetailView(contactListViewModel: viewModel, isShowingNewInteractionView: isShowingNewInteractionView, contact: contact)
                        case .settings:
                            SettingsView()
                        case .newContact:
                            ContactDetailView(contactListViewModel: viewModel, isShowingNewInteractionView: false, contact: Contact())
                        case .fromContacts:
                            ContactPickerView { contact in
                                viewModel.navigationPath.removeLast()
                                viewModel.navigationPath.append(ContactRoute.detail(contact: contact))
                            }
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
                            Menu {
                                Button(action: {
                                    viewModel.navigationPath.append(ContactRoute.newContact)
                                }) {
                                    Label("New", systemImage: "person.fill.badge.plus")
                                }

                                Button(action: {
                                    viewModel.checkContactsPermission()
                                }) {
                                    Label("From contacts", systemImage: "person.crop.circle.fill.badge.plus")
                                }
                            } label: {
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                            }
                            .alert("Contacts Access Required", isPresented: $viewModel.showContactsPermissionAlert) {
                                Button("Настройки", role: .none) {
                                    viewModel.openAppSettings()
                                }
                                Button("Cancel", role: .cancel) {}
                            } message: {
                                Text("To grant contacts access:\n1. Open Settings\n2. Go to Privacy\n3. Select Contacts\n4. Find this app\n5. Enable access")
                            }
                        }
                    }
                }
            }
            .onNotification { notification in
                DispatchQueue.main.async {
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
    let onAddAction: () -> Void

    var body: some View {
        HStack {
            ZStack(alignment: .topTrailing) {
                Text(contact.imageName)
                    .font(.system(size: 40))
                    .padding(.horizontal, 2) // Уменьшенный горизонтальный padding

                if contact.countMessages > 0 {
                    Text("\(contact.countMessages)")
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue)
                        .clipShape(Capsule())
                        .offset(x: 5, y: -5)
                }
            }

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
                    if let lastMessage = contact.lastMessage {
                        Text("Talked \(lastMessage, format: .dateTime.day().month().year())")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                }
                Spacer()
            }.padding(.leading, 4)

            Spacer()

            Button(action: onAddAction) {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                    .frame(width: 44, height: 44)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .padding(.trailing, 2) // Уменьшенный padding справа
        }
    }
}
