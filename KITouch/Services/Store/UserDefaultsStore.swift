//
//  UserDefaultsStore.swift
//  KITouch
//
//  Created by Роман Вертячих on 11.06.2025.
//

import Foundation

final class UserDefaultsStore {
    
    //MARK: - Properties
    
    enum Key: String {
        case pendingContactId
    }
    
    private let userDefaults = UserDefaults.standard
    
    //MARK: - Function
    
    func setString(_ value: String, key: Key) {
        userDefaults.set(value, forKey: key.rawValue)
    }
    
    func getString(key: Key) -> String? {
        userDefaults.string(forKey: key.rawValue)
    }
    
    func removeString(key: Key) {
        userDefaults.removeObject(forKey: key.rawValue)
        // Обязательно synchronize(), чтобы убедиться, что изменения сохранены
        userDefaults.synchronize()
    }
}
