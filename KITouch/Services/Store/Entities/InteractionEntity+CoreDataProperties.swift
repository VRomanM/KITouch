//
//  InteractionEntity+CoreDataProperties.swift
//  KITouch
//
//  Created by Alexey Chanov on 27.06.2025.
//
//

import Foundation
import CoreData


extension InteractionEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InteractionEntity> {
        return NSFetchRequest<InteractionEntity>(entityName: "InteractionEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var notes: String?
    @NSManaged public var contactId: UUID?
    @NSManaged public var relationship: ContactEntity?

}

extension InteractionEntity : Identifiable {

}
