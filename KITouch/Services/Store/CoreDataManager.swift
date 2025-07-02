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
        static let dbName           = "Model"
    }
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Constants.dbName)
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
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
        
    //MARK: - Function
    
    ///MARK: - Contact
    
    func saveContact(contact: Contact, completion: @escaping (_ success: Bool) -> Void) {
        let managedContext = persistentContainer.viewContext
        let entity: ContactEntity
        
        if let contactEntity = retrieveContact(by: contact.id) {
            
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
                
        entity.name                 = contact.name
        entity.contactType          = contact.contactType
        entity.customContactType    = contact.customContactType
        entity.imageName            = contact.imageName
        entity.lastMessage          = contact.lastMessage
        entity.countMessages        = Int16(contact.countMessages)
        entity.phone                = contact.phone
        entity.birthday             = contact.birthday
        entity.connectChannelEntity = NSSet(array: channels)
              
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
                Interaction(
                    id: entity.id ?? UUID(), // Используем ID из базы данных
                    date: entity.date ?? Date(),
                    notes: entity.notes ?? "",
                    contactId: entity.contactId ?? UUID()
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
            print("Поиск взаимодействия с ID: \(interaction.id)")
            print("Найдено записей: \(results.count)")

            if let entity = results.first {
                entity.date = interaction.date
                entity.notes = interaction.notes
                entity.contactId = interaction.contactId

                try context.save()
                completion(.success(()))
            } else {
                // Попробуем найти все записи для отладки
                let debugRequest: NSFetchRequest<InteractionEntity> = InteractionEntity.fetchRequest()
                let allEntities = try context.fetch(debugRequest)
                print("Всего записей в базе: \(allEntities.count)")
                for entity in allEntities {
                    print("ID в базе: \(entity.id?.uuidString ?? "nil")")
                }

                let error = NSError(domain: "InteractionNotFound", code: 404,
                                  userInfo: [NSLocalizedDescriptionKey: "Interaction with ID \(interaction.id) not found"])
                completion(.failure(error))
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
}
