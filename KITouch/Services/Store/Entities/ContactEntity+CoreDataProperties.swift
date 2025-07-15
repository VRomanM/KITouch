//
//  ContactEntity+CoreDataProperties.swift
//  KITouch
//
//  Created by Роман Вертячих on 14.06.2025.
//
//

import Foundation
import CoreData


extension ContactEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContactEntity> {
        return NSFetchRequest<ContactEntity>(entityName: "ContactEntity")
    }

    @NSManaged public var birthday: Date
    @NSManaged public var contactType: String
    @NSManaged public var countMessages: Int16
    @NSManaged public var customContactType: String
    @NSManaged public var id: UUID
    @NSManaged public var imageName: String
    @NSManaged public var lastMessage: Date?
    @NSManaged public var name: String
    @NSManaged public var phone: String
    @NSManaged public var reminder: Bool
    @NSManaged public var reminderDate: Date
    @NSManaged public var reminderRepeat: String
    @NSManaged public var reminderBirthday: Bool
    @NSManaged public var systemContactId: String?
    @NSManaged public var connectChannelEntity: NSSet?

    var idString: String { id.uuidString }
}

// MARK: Generated accessors for connectChannelEntity
extension ContactEntity {

    @objc(addConnectChannelEntityObject:)
    @NSManaged public func addToConnectChannelEntity(_ value: ConnectChannelEntity)

    @objc(removeConnectChannelEntityObject:)
    @NSManaged public func removeFromConnectChannelEntity(_ value: ConnectChannelEntity)

    @objc(addConnectChannelEntity:)
    @NSManaged public func addToConnectChannelEntity(_ values: NSSet)

    @objc(removeConnectChannelEntity:)
    @NSManaged public func removeFromConnectChannelEntity(_ values: NSSet)

}

extension ContactEntity : Identifiable {

}
