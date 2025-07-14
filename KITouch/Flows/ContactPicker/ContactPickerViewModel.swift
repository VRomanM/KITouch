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
    @Published var showDuplicateAlert = false
    @Published var duplicateContact: Contact?
    
    private let contactStore = CNContactStore()
    private let coreDataManager = CoreDataManager.sharedManager
    
    func loadContacts() async {
        do {
            let keysToFetch = [
                CNContactGivenNameKey,
                CNContactFamilyNameKey,
                CNContactPhoneNumbersKey,
                CNContactBirthdayKey,
                CNContactIdentifierKey,
                CNContactEmailAddressesKey
            ] as [CNKeyDescriptor]
            
            let request = CNContactFetchRequest(keysToFetch: keysToFetch)
            
            // Выполняем тяжелую работу в фоновом потоке
            let fetchedContacts = try await Task.detached(priority: .userInitiated) { [request, contactStore] () -> [Contact] in
                var contacts: [Contact] = []
                try contactStore.enumerateContacts(with: request) { cnContact, _ in
                    // Создаем каналы связи для контакта
                    var connectChannels: [ConnectChannel] = []
                    
                    // Добавляем email если есть
                    if let email = cnContact.emailAddresses.first?.value as String? {
                        connectChannels.append(ConnectChannel(socialMediaType: .email, login: email))
                    }
                    
                    let newContact = Contact(
                        name: "\(cnContact.givenName) \(cnContact.familyName)".trimmingCharacters(in: .whitespaces),
                        contactType: ContactType.friend.rawValue,
                        imageName: "😎",
                        lastMessage: Date.distantPast,
                        countMessages: 0,
                        phone: cnContact.phoneNumbers.first?.value.stringValue ?? "",
                        birthday: cnContact.birthday?.date,
                        connectChannels: connectChannels,
                        systemContactId: cnContact.identifier
                    )
                    contacts.append(newContact)
                }
                return contacts.sorted { $0.name < $1.name }
            }.value
            
            // Обновляем UI в главном потоке
            await MainActor.run {
                self.contacts = fetchedContacts
            }
        } catch let error {
            print("Error fetching contacts: \(error)")
        }
    }
    
    func checkForDuplicate(contact: Contact) async -> Contact? {
        guard let systemContactId = contact.systemContactId else { return nil }
        
        return await Task.detached(priority: .userInitiated) { [coreDataManager] () -> Contact? in
            var duplicateContact: Contact?
            let semaphore = DispatchSemaphore(value: 0)
            
            coreDataManager.retrieveContacts { success, contactEntities in
                if success, let entities = contactEntities {
                    if let existingEntity = entities.first(where: { $0.systemContactId == systemContactId }) {
                        // Преобразование ConnectChannelEntity в ConnectChannel
                        let connectChannels: [ConnectChannel] = (existingEntity.connectChannelEntity as? Set<ConnectChannelEntity> ?? [])
                            .compactMap { channelEntity in
                                let socialMediaType = SocialMediaType(rawValue: channelEntity.socialMediaType) ?? .email
                                return ConnectChannel(
                                    id: channelEntity.id,
                                    socialMediaType: socialMediaType,
                                    login: channelEntity.login
                                )
                            }
                        
                        duplicateContact = Contact(
                            id: existingEntity.id,
                            name: existingEntity.name,
                            contactType: existingEntity.contactType,
                            customContactType: existingEntity.customContactType,
                            imageName: existingEntity.imageName,
                            lastMessage: existingEntity.lastMessage,
                            countMessages: Int(existingEntity.countMessages),
                            phone: existingEntity.phone,
                            birthday: existingEntity.birthday,
                            reminder: existingEntity.reminder,
                            reminderDate: existingEntity.reminderDate,
                            reminderRepeat: existingEntity.reminderRepeat,
                            reminderBirthday: existingEntity.reminderBirthday,
                            connectChannels: connectChannels,
                            systemContactId: existingEntity.systemContactId
                        )
                    }
                }
                semaphore.signal()
            }
            
            semaphore.wait()
            return duplicateContact
        }.value
    }
}
