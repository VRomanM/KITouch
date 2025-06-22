//
//  NotificationManager.swift
//  KITouch
//
//  Created by Роман Вертячих on 21.06.2025.
//

import UserNotifications

final class NotificationManager {
    
    //MARK: - Private properties
    
    private let coreDataManager = CoreDataManager.sharedManager
    
    //MARK: - Properties
    
    static let sharedManager = NotificationManager()
    
    //MARK: - Constructions
    
    private init() {}
    
    //MARK: - Private function

    private func removeScheduledNotifications(for contact: Contactable) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["birthday_\(contact.idString)"])
    }
    
    //MARK: - Function
    
    func requestNotificationAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Success")
            } else if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func checkAndRescheduleBirthdayNotifications() {
        coreDataManager.retrieveContacts { [weak self] _, contacts in
            DispatchQueue.main.async {
                if let contacts = contacts {
                    for contact in contacts {
                        self?.scheduleBirthdayNotification(for: contact)
                    }
                }
            }
        }
    }
    
    func scheduleBirthdayNotification<T: Contactable>(for contact: T) {
        removeScheduledNotifications(for: contact)
        
        guard let birthday = contact.birthday else { return }
        
        let calendar = Calendar.current
        let birthdayComponents = calendar.dateComponents([.day, .month], from: birthday)
        
        var dateComponents      = DateComponents()
        dateComponents.day      = birthdayComponents.day
        dateComponents.month    = birthdayComponents.month
        dateComponents.hour     = 10
        
        //Для тестирования ->
        let currentDateComponents = calendar.dateComponents([.day, .month, .hour, .minute], from: Date())
        dateComponents.day      = currentDateComponents.day
        dateComponents.month    = currentDateComponents.month
        dateComponents.hour     = currentDateComponents.hour
        dateComponents.minute   = currentDateComponents.minute! + 1
        //Для тестирования <-
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Создаем содержимое уведомления
        let content = UNMutableNotificationContent()
        content.title           = NSLocalizedString("Birthday!", comment: "")
        content.body            = NSLocalizedString("Today is the birthday of \(contact.name)", comment: "")
        content.sound           = UNNotificationSound.default
        content.userInfo        = [
            "contactId": contact.idString,
            "navigation": "contactDetail"
        ]
        content.categoryIdentifier = "BIRTHDAY_CATEGORY"
        content.threadIdentifier = "birthday_notifications"
        
        // Добавляем deep link для открытия конкретного контакта
        if let deepLink = URL(string: "yourapp://contacts/\(contact.idString)") {
            content.userInfo["deepLink"] = deepLink.absoluteString
        }
        
        // Создаем запрос
        let request = UNNotificationRequest(
            identifier: "birthday_\(contact.idString)",
            content: content,
            trigger: trigger
        )
        
        // Добавляем запрос в центр уведомлений
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            } else {
                print("Notification added for \(contact.name)")
            }
        }
    }
}
