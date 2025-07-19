//
//  ContactPickerViewModel.swift
//  KITouch
//
//  Created by Роман Вертячих on 14.07.2025.
//
import Combine
import ContactsUI

// MARK: - System Contact Helper
enum SystemContactHelper {
    static let keysToFetch: [CNKeyDescriptor] = [
        CNContactGivenNameKey,
        CNContactFamilyNameKey,
        CNContactPhoneNumbersKey,
        CNContactBirthdayKey,
        CNContactIdentifierKey,
        CNContactEmailAddressesKey
    ] as [CNKeyDescriptor]
    
    static func createContact(from cnContact: CNContact) -> Contact {
        // Создаем каналы связи для контакта
        var connectChannels: [ConnectChannel] = []
        
        // Добавляем email если есть
        if let email = cnContact.emailAddresses.first?.value as String? {
            connectChannels.append(ConnectChannel(socialMediaType: .email, login: email))
        }
        
        return Contact(
            name: "\(cnContact.givenName) \(cnContact.familyName)".trimmingCharacters(in: .whitespaces),
            contactType: ContactType.friend.rawValue,
            isNewContact: true,
            imageName: "😎",
            lastMessage: Date.distantPast,
            countMessages: 0,
            phone: cnContact.phoneNumbers.first?.value.stringValue ?? "",
            birthday: cnContact.birthday?.date,
            connectChannels: connectChannels,
            systemContactId: cnContact.identifier
        )
    }
    
    static func fetchSystemContact(with identifier: String) async throws -> Contact? {
        let store = CNContactStore()
        
        do {
            let cnContact = try store.unifiedContact(withIdentifier: identifier, keysToFetch: keysToFetch)
            return createContact(from: cnContact)
        } catch {
            print("Error fetching contact: \(error)")
            return nil
        }
    }
}

@MainActor
final class ContactPickerViewModel: ObservableObject {
    @Published private(set) var contacts: [Contact] = []
    @Published var searchQuery = ""
    @Published var showDuplicateAlert = false
    @Published var duplicateContact: Contact?

    private let contactStore = CNContactStore()
    private let coreDataManager = CoreDataManager.sharedManager

    // MARK: - Computed Properties
    var filteredContacts: [Contact] {
        if searchQuery.isEmpty {
            return contacts
        }
        return contacts.filter { contact in
            contact.name.localizedCaseInsensitiveContains(searchQuery) ||
            contact.phone.localizedCaseInsensitiveContains(searchQuery)
        }
    }

    // MARK: - Public Methods
    func clearSearch() {
        searchQuery = ""
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    func handleContactSelection(_ contact: Contact, completion: @escaping (Contact?) -> Void) {
        Task {
            if let duplicateContact = await checkForDuplicate(contact: contact) {
                await MainActor.run {
                    self.duplicateContact = duplicateContact
                    self.showDuplicateAlert = true
                }
            } else {
                await MainActor.run {
                    completion(nil)
                }
            }
        }
    }

    func loadContacts() async {
        do {
            let request = CNContactFetchRequest(keysToFetch: SystemContactHelper.keysToFetch)

            let fetchedContacts = try await Task.detached(priority: .userInitiated) { [request, contactStore] () -> [Contact] in
                var contacts: [Contact] = []
                try contactStore.enumerateContacts(with: request) { cnContact, _ in
                    contacts.append(SystemContactHelper.createContact(from: cnContact))
                }
                return contacts.sorted { $0.name < $1.name }
            }.value

            await MainActor.run {
                self.contacts = fetchedContacts
            }
        } catch let error {
            print("Error fetching contacts: \(error)")
        }
    }

    // MARK: - Private Methods
    private func checkForDuplicate(contact: Contact) async -> Contact? {
        guard let systemContactId = contact.systemContactId else { return nil }

        return await Task.detached(priority: .userInitiated) { [coreDataManager] () -> Contact? in
            let (success, contactEntities): (Bool, [ContactEntity]?) = await withCheckedContinuation { continuation in
                var hasResumed = false
                coreDataManager.retrieveContacts { success, entities in
                    guard !hasResumed else { return }
                    hasResumed = true
                    continuation.resume(returning: (success, entities))
                }
            }

            guard success, let entities = contactEntities else { return nil }

            guard let existingEntity = entities.first(where: { $0.systemContactId == systemContactId }) else {
                return nil
            }

            let connectChannels: [ConnectChannel] = (existingEntity.connectChannelEntity as? Set<ConnectChannelEntity> ?? [])
                .compactMap { channelEntity in
                    let socialMediaType = SocialMediaType(rawValue: channelEntity.socialMediaType) ?? .email
                    return ConnectChannel(
                        id: channelEntity.id,
                        socialMediaType: socialMediaType,
                        login: channelEntity.login
                    )
                }

            return Contact(
                id: existingEntity.id,
                name: existingEntity.name,
                contactType: existingEntity.contactType,
                customContactType: existingEntity.customContactType,
                imageName: existingEntity.imageName,
                lastMessage: existingEntity.lastMessage ?? Date.now,
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
        }.value
    }
}
