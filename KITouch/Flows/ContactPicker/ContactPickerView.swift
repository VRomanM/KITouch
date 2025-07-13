//
//  ContactPickerView.swift
//  KITouch
//
//  Created by Роман Вертячих on 30.06.2025.
//

import ContactsUI
import SwiftUI

struct ContactPickerView: UIViewControllerRepresentable {
    var onSelectContact: (Contact) -> Void
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CNContactPickerDelegate {
        var parent: ContactPickerView
        
        init(_ parent: ContactPickerView) {
            self.parent = parent
        }
        
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            // Конвертируем CNContact в наш Contact
            let newContact = Contact(name: "\(contact.givenName) \(contact.familyName)",
                                     contactType: "Friend",
                                     isNewContact: true,
                                     imageName: "😎",
                                     lastMessage: nil,
                                     countMessages: 0,
                                     phone: contact.phoneNumbers.first?.value.stringValue ?? "",
                                     birthday: contact.birthday?.date,
                                     connectChannels: [ConnectChannel]()
            )
            
            // Можно добавить больше полей из CNContact по необходимости
            parent.onSelectContact(newContact)
        }
    }
}
