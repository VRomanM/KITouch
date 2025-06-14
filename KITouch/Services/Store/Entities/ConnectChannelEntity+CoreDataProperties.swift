//
//  ConnectChannelEntity+CoreDataProperties.swift
//  KITouch
//
//  Created by Роман Вертячих on 14.06.2025.
//
//

import Foundation
import CoreData


extension ConnectChannelEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ConnectChannelEntity> {
        return NSFetchRequest<ConnectChannelEntity>(entityName: "ConnectChannelEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var login: String
    @NSManaged public var socialMediaType: String
    @NSManaged public var contactEntity: ContactEntity?

}

extension ConnectChannelEntity : Identifiable {

}
