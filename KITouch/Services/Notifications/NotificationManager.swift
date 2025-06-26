//
//  NotificationManager.swift
//  KITouch
//
//  Created by Роман Вертячих on 21.06.2025.
//

import UserNotifications

final class NotificationManager: ObservableObject {
    
    //MARK: - Private properties
    
    @Published private(set) var latestNotification: UNNotificationResponse? = .none // default value
    private let coreDataManager = CoreDataManager.sharedManager
    
    //MARK: - Properties
    
    static let sharedManager = NotificationManager()
    
    //MARK: - Constructions
    
    private init() {}
    
    //MARK: - Private function

    private func removeScheduledNotifications(for contact: Contact) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["birthday_\(contact.idString)"])
    }
    
    //MARK: - Function
    
    func handle(notification: UNNotificationResponse) {
        self.latestNotification = notification
    }
    
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
    
    func scheduleBirthdayNotification(for contact: Contact) {
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
        content.title           = "Birthday%@".localized(with: "!")
        content.body            = "Today is the birthday of %@".localized(with: contact.name)
        content.sound           = UNNotificationSound.default
        content.userInfo        = [
            "contactId": contact.idString
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
