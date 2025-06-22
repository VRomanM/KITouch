//
//  ContactListView.swift
//  KiTouch
//
//  Created by Роман Вертячих on 28.05.2025.
//

import SwiftUI

struct ContactListView: View {
    @StateObject var viewModel = ContactListViewModel()
    @State var store = UserDefaultsStore()
    @State private var selectedContactId: String?
//    @State private var isInitialLoad = true

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
                        ForEach(viewModel.filteredContacts()) { contact in
//                            NavigationLink(value: contact) {
//                                ContactView(contact: contact)
//                            }
                            NavigationLink(
                                destination: ContactDetailView(contactListViewModel: viewModel, contact: contact),
                                tag: contact.idString, selection: $selectedContactId) {
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
                                viewModel.showSettings = true
                            }) {
                                Image(systemName: "line.horizontal.3")
                                    .foregroundColor(.white)
                            }
                        }

                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                viewModel.showNew = true
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
                                  contact: contact)
            }
            .navigationDestination(isPresented: $viewModel.showNew) {
                ContactDetailView(contactListViewModel: viewModel,
                                  contact: Contact())
            }
            .navigationDestination(isPresented: $viewModel.showSettings) {
                SettingsView()
            }
            .onOpenURL { url in
                // Обработка deep links
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenContactDetail"))) { notification in
                if let contactId = notification.userInfo?["contactId"] as? String {
                    selectedContactId = contactId
                }
            }
//            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
//                // Проверяем, есть ли контакт для открытия при запуске
//                
////                if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
//                if let appDelegate = UNUserNotificationCenter.current().delegate as? AppDelegate,
//                   let contactId = appDelegate.pendingContactId {
//                    selectedContactId = contactId
//                    appDelegate.pendingContactId = nil
//                }
//            }
//            .onAppear {
//                if isInitialLoad {
//                    // Проверяем сохраненный contactId при первом открытии
//                    if let contactId = store.getString(key: .pendingContactId) {
//                        selectedContactId = contactId
//                        store.removeString(key: .pendingContactId)
//                    }
//                    isInitialLoad = false
//                }
//            }
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
                Text(NSLocalizedString(contact.name, comment: ""))
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(NSLocalizedString(contact.contactType, comment: ""))
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
