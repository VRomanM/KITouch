//
//  ContactPickerViewModel.swift
//  KITouch
//
//  Created by Роман Вертячих on 14.07.2025.
//
import Combine
import ContactsUI

@MainActor
final class ContactPickerViewModel: ObservableObject {
    @Published private(set) var contacts: [Contact] = []
    private let contactStore = CNContactStore()
    
    func loadContacts() async {
        do {
            let keysToFetch = [
                CNContactGivenNameKey,
                CNContactFamilyNameKey,
                CNContactPhoneNumbersKey,
                CNContactBirthdayKey
            ] as [CNKeyDescriptor]
            
            let request = CNContactFetchRequest(keysToFetch: keysToFetch)
            
            // Выполняем тяжелую работу в фоновом потоке
            let fetchedContacts = try await Task.detached(priority: .userInitiated) { [request, contactStore] () -> [Contact] in
                var contacts: [Contact] = []
                try contactStore.enumerateContacts(with: request) { cnContact, _ in
                    let newContact = Contact(
                        name: "\(cnContact.givenName) \(cnContact.familyName)".trimmingCharacters(in: .whitespaces),
                        contactType: "Friend",
                        imageName: "😎",
                        lastMessage: Date.distantPast,
                        countMessages: 0,
                        phone: cnContact.phoneNumbers.first?.value.stringValue ?? "",
                        birthday: cnContact.birthday?.date,
                        connectChannels: []
                    )
                    contacts.append(newContact)
                }
                return contacts.sorted { $0.name < $1.name }
            }.value
            
            // Обновляем UI в главном потоке
            await MainActor.run {
                self.contacts = fetchedContacts
            }
        } catch {
            print("Error fetching contacts: \(error)")
        }
    }
}
