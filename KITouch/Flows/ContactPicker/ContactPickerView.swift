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
        List {
            ForEach(viewModel.contacts) { contact in
                Button {
                    handleContactSelection(contact)
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
    
    private func handleContactSelection(_ contact: Contact) {
        Task {
            if let duplicateContact = await viewModel.checkForDuplicate(contact: contact) {
                viewModel.duplicateContact = duplicateContact
                viewModel.showDuplicateAlert = true
            } else {
                onSelectContact(contact)
            }
        }
    }
}

//struct ContactPickerView: UIViewControllerRepresentable {
//    var onSelectContact: (Contact) -> Void
//    
//    func makeUIViewController(context: Context) -> some UIViewController {
//        let picker = CNContactPickerViewController()
//        picker.delegate = context.coordinator
//        return picker
//    }
//    
//    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    class Coordinator: NSObject, CNContactPickerDelegate {
//        var parent: ContactPickerView
//        
//        init(_ parent: ContactPickerView) {
//            self.parent = parent
//        }
//        
//        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
//            // Конвертируем CNContact в наш Contact
//            let newContact = Contact(name: "\(contact.givenName) \(contact.familyName)",
//                                     contactType: "Friend",
//                                     imageName: "😎",
//                                     lastMessage: Date.distantPast,
//                                     countMessages: 0,
//                                     phone: contact.phoneNumbers.first?.value.stringValue ?? "",
//                                     birthday: contact.birthday?.date,
//                                     connectChannels: [ConnectChannel]()
//            )
//            
//            // Можно добавить больше полей из CNContact по необходимости
//            parent.onSelectContact(newContact)
//        }
//    }
//}
