//
//  CoreDataManager.swift
//  KITouch
//
//  Created by Роман Вертячих on 11.06.2025.
//

import CoreData

final class CoreDataManager {
    
    //MARK: - Private properties
    
    private struct Constants {
        static let dbName           = "Models"
    }
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Constants.dbName)
        
        // Включаем автоматическую миграцию
        let description = container.persistentStoreDescriptions.first
        description?.shouldMigrateStoreAutomatically = true
        description?.shouldInferMappingModelAutomatically = true
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
                
                //MARK: -> Только для разработки!
//                // Если сломалось хранилище CoreData в Previews. Пытаемся пересоздать его, а вместо fatalError просто выводим ошибку
//                print("⚠️ Core Data error: \(error), \(error.userInfo)")
//                
//                // Попытка пересоздать хранилище (только для разработки!)
//                if let storeURL = description?.url {
//                    try? FileManager.default.removeItem(at: storeURL)
//                    container.loadPersistentStores { _, _ in }
//                }
                //MARK: <- Только для разработки!
            }
        }
        return container
    }()
    enum Entities: String {
        case contact                = "ContactEntity"
        case connectChannels        = "ConnectChannelsEntity"
        case interaction            = "InteractionEntity"
    }
    
    //MARK: - Properties
    
    static let sharedManager = CoreDataManager()
    
    //MARK: - Constructions
    
    private init() {}
    
    //MARK: - Private function
    
    private func retrieveDataEntity<T>(fetchRequest: NSFetchRequest<T>, completion: @escaping (_ success: Bool, _ results: [T]?) -> Void) {
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            completion(true, results)
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            completion(false, nil)
        }
    }
    
    private func deleteDataEntity(fetchRequest: NSFetchRequest<NSFetchRequestResult>, completion: @escaping (_ results: NSPersistentStoreResult?, _ error: NSError?) -> Void) {
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        let managedContext = persistentContainer.viewContext
        do {
            let results = try managedContext.execute(deleteRequest)
            completion(results, nil)
        } catch let error as NSError {
            completion(nil, error)
        }
    }
    
    private func retrieveContact(by id: UUID) -> ContactEntity? {
        var contactEntity: ContactEntity?
        let fetchRequest: NSFetchRequest<ContactEntity> = ContactEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        retrieveDataEntity(fetchRequest: fetchRequest) { success, contact in
            if contact?.count == 0 {
                contactEntity = nil
            } else {
                contactEntity = contact?[0]
            }
        }
        
        return contactEntity
    }
    
    private func retrieveContactBySystemId(_ systemId: String) -> ContactEntity? {
        var contactEntity: ContactEntity?
        let fetchRequest: NSFetchRequest<ContactEntity> = ContactEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "systemContactId == %@", systemId as CVarArg)
        fetchRequest.fetchLimit = 1
        
        retrieveDataEntity(fetchRequest: fetchRequest) { success, contact in
            if contact?.count == 0 {
                contactEntity = nil
            } else {
                contactEntity = contact?[0]
            }
        }
        
        return contactEntity
    }
        
    //MARK: - Function
    
    ///MARK: - Contact
    
    func saveContact(contact: Contact, completion: @escaping (_ success: Bool) -> Void) {
        let managedContext = persistentContainer.viewContext
        let entity: ContactEntity
        
        // Если это контакт из системной адресной книги, сначала ищем по systemContactId
        if let systemId = contact.systemContactId,
           let existingContact = retrieveContactBySystemId(systemId) {
            entity = existingContact
        } else if let contactEntity = retrieveContact(by: contact.id) {
            entity = contactEntity
        } else {
            entity = ContactEntity(context: managedContext)
            entity.id = contact.id
        }
        
        let channels: [ConnectChannelEntity] = {
            var channels: [ConnectChannelEntity] = []
            for connectChannel in contact.connectChannels {
                let channel = ConnectChannelEntity(context: managedContext)
                channel.id              = connectChannel.id
                channel.login           = connectChannel.login
                channel.socialMediaType = connectChannel.socialMediaType.rawValue
                channels.append(channel)
            }
            return channels
        }()
                
        entity.name                             = contact.name
        entity.contactType                      = contact.contactType
        entity.customContactType                = contact.customContactType
        entity.imageName                        = contact.imageName
        entity.lastMessage                      = contact.lastMessage ?? nil
        entity.countMessages                    = Int16(contact.countMessages)
        entity.phone                            = contact.phone
        entity.birthday                         = contact.birthday
        entity.reminder                         = contact.reminder
        entity.reminderDate                     = contact.reminderDate
        entity.reminderRepeat                   = contact.reminderRepeat
        entity.reminderBirthday                 = contact.reminderBirthday
        entity.reminderBeforeBirthday           = contact.reminderBeforeBirthday
        entity.reminderCountDayBeforeBirthday   = Int16(contact.reminderCountDayBeforeBirthday)
        entity.systemContactId                  = contact.systemContactId
        entity.connectChannelEntity             = NSSet(array: channels)
              
        do {
            try managedContext.save()
            completion(true)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            completion(false)
        }
    }
    
    func retrieveContacts(completion: @escaping (_ success: Bool, _ contactEntity: [ContactEntity]?) -> Void) {
        let fetchRequest = NSFetchRequest<ContactEntity>(entityName: Entities.contact.rawValue)
        
        retrieveDataEntity(fetchRequest: fetchRequest) { success, contact in
            if contact?.count == 0 {
                completion(false, nil)
            }
            completion(success, contact)
        }
            
    }
    
    func deleteContact(_ contact: Contact, completion: @escaping (Result<Void, Error>) -> Void) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Entities.contact.rawValue)
        request.predicate = NSPredicate(format: "id == %@", contact.id as CVarArg)
        
        deleteDataEntity(fetchRequest: request) { results, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updateData() {
        
    }

    ///MARK: - Interaction
    
    func saveInteraction(interaction: Interaction, completion: @escaping (Bool) -> Void) {
        let context = persistentContainer.viewContext
        let interactionEntity = InteractionEntity(context: context)
        interactionEntity.id = interaction.id 
        interactionEntity.date = interaction.date
        interactionEntity.notes = interaction.notes
        interactionEntity.contactId = interaction.contactId
        
        // Сохраняем тип взаимодействия
        switch interaction.type {
        case .call, .meeting, .message:
            interactionEntity.type = String(describing: interaction.type)
            interactionEntity.socialMediaType = nil
            interactionEntity.socialMediaLogin = nil
        case .socialMedia(let socialType, let login):
            interactionEntity.type = "socialMedia"
            interactionEntity.socialMediaType = socialType.rawValue
            interactionEntity.socialMediaLogin = login
        }

        do {
            try context.save()
            completion(true)
        } catch {
            print("Ошибка сохранения взаимодействия: \(error)")
            completion(false)
        }
    }

    func fetchInteractions(for contactId: UUID, completion: @escaping ([Interaction]) -> Void) {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<InteractionEntity> = InteractionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "contactId == %@", contactId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \InteractionEntity.date, ascending: false)]

        do {
            let interactionEntities = try context.fetch(request)
            let interactions = interactionEntities.map { entity in
                let type: InteractionType = {
                    if let typeString = entity.type {
                        if typeString == "socialMedia",
                           let socialMediaTypeString = entity.socialMediaType,
                           let socialMediaType = SocialMediaType(rawValue: socialMediaTypeString) {
                            return .socialMedia(socialMediaType, entity.socialMediaLogin ?? "")
                        } else {
                            switch typeString {
                            case "call": return .call
                            case "meeting": return .meeting
                            case "message": return .message
                            default: return .call // Значение по умолчанию
                            }
                        }
                    }
                    return .call // Значение по умолчанию
                }()
                
                return Interaction(
                    id: entity.id ?? UUID(),
                    date: entity.date ?? Date(),
                    notes: entity.notes ?? "",
                    contactId: entity.contactId ?? UUID(),
                    type: type
                )
            }
            completion(interactions)
        } catch {
            print("Ошибка загрузки взаимодействий: \(error)")
            completion([])
        }
    }

    func updateInteraction(interaction: Interaction, completion: @escaping (Result<Void, Error>) -> Void) {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<InteractionEntity> = InteractionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", interaction.id as CVarArg)

        do {
            let results = try context.fetch(request)
            if let interactionEntity = results.first {
                interactionEntity.date = interaction.date
                interactionEntity.notes = interaction.notes
                
                // Обновляем тип взаимодействия
                switch interaction.type {
                case .call, .meeting, .message:
                    interactionEntity.type = String(describing: interaction.type)
                    interactionEntity.socialMediaType = nil
                    interactionEntity.socialMediaLogin = nil
                case .socialMedia(let socialType, let login):
                    interactionEntity.type = "socialMedia"
                    interactionEntity.socialMediaType = socialType.rawValue
                    interactionEntity.socialMediaLogin = login
                }
                
                try context.save()
                completion(.success(()))
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Взаимодействие не найдено"])))
            }
        } catch {
            completion(.failure(error))
        }
    }

    func deleteInteraction(_ interaction: Interaction, completion: @escaping (Result<Void, Error>) -> Void) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Entities.interaction.rawValue)
        request.predicate = NSPredicate(format: "id == %@", interaction.id as CVarArg)
        
        deleteDataEntity(fetchRequest: request) { results, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func fetchLatestInteraction(for contactId: UUID, completion: @escaping (Interaction?) -> Void) {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<InteractionEntity> = InteractionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "contactId == %@", contactId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \InteractionEntity.date, ascending: false)]
        request.fetchLimit = 1

        do {
            if let entity = try context.fetch(request).first {
                let interaction = Interaction(
                    id: entity.id ?? UUID(),
                    date: entity.date ?? Date(),
                    notes: entity.notes ?? "",
                    contactId: entity.contactId ?? UUID()
                )
                completion(interaction)
            } else {
                completion(nil)
            }
        } catch {
            print("Ошибка загрузки взаимодействий: \(error)")
            completion(nil)
        }
    }
}
