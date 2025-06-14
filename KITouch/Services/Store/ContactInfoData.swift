//
//  ContactInfoData.swift
//  KITouch
//
//  Created by Роман Вертячих on 11.06.2025.
//

import CoreData

class ContactInfoData {
    static var contact: Contact?
    
    static func transformToContact(contactEntity: ContactEntity) -> Contact? {
        guard let contact = contact else { return nil }
        
        guard let channelsSet = contactEntity.connectChannelEntity as? Set<ConnectChannelEntity> else { return nil }
        
        var connectChannels = [ConnectChannel]()
        
        for channelEntity in channelsSet {
//            if let channelEntity = channelEntity as? ConnectChannelEntity {
//                ConnectChannel(id: channelEntity.id, socialMediaType: SocialMediaType(rawValue: channelEntity.socialMediaType), login: channelEntity.login)
//            }
            connectChannels.append(ConnectChannel(id: channelEntity.id!,
                           socialMediaType: SocialMediaType(rawValue: channelEntity.socialMediaType!)!,
                           login: channelEntity.login!))
        }
        
        return Contact(id: contact.id, name: contact.name, contactType: contact.contactType, imageName: contact.imageName, lastMessage: contact.lastMessage, countMessages: contact.countMessages, phone: contact.phone, birthday: contact.birthday, connectChannels: connectChannels)
    }
}
