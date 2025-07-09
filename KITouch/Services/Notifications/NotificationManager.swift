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
    private let center = UNUserNotificationCenter.current()
    
    //MARK: - Properties
    
    static let sharedManager = NotificationManager()
    enum ReminderType: String, CaseIterable {
        case birthday = "birthdayReminder:"
        case beforeBirthday = "beforeBirthdayReminder:"
        case regular = "regularReminder:"
        case regularHalfYear = "regularHalfYear:"
    }
    
    //MARK: - Constructions
    
    private init() {}
    
    //MARK: - Private function
    
    private func getNotificationIdentifier(for contact: Contact, type: ReminderType) -> String {
        return "\(type.rawValue)\(contact.idString)"
    }
    
    private func removeScheduledNotifications(for contact: Contact, type: ReminderType) {
        center.removePendingNotificationRequests(withIdentifiers: [getNotificationIdentifier(for: contact, type: type)])
    }
    
    private func getNotificationTrigger(startDate: Date, repeatPeriod: NotificationPeriod, debug: Bool) -> UNCalendarNotificationTrigger {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        
        switch repeatPeriod {
            
        case .daily:
            dateComponents = calendar.dateComponents([.hour, .minute], from: startDate)
        case .weekly:
            dateComponents = calendar.dateComponents([.weekday, .hour, .minute], from: startDate)
        case .monthly:
            dateComponents = calendar.dateComponents([.day, .hour, .minute], from: startDate)
        case .halfYearly:
            // Высчитываем полгода от месяца startDate через остаток от деления
            var nextMonth: Int?
            dateComponents = calendar.dateComponents([.month, .day, .hour, .minute], from: startDate)
            if let month = dateComponents.month {
                if month == 6 {
                    nextMonth = 12
                } else if month == 12 {
                    nextMonth = 6
                } else if month < 6 {
                    nextMonth = month % 6 + 6
                } else if month > 6 {
                    nextMonth = month % 6
                }
                dateComponents.month = nextMonth
            }
        case .yearly:
            dateComponents = calendar.dateComponents([.month, .day, .hour, .minute], from: startDate)
        case .never:
            dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: startDate)
        }
        
        if debug {
            dateComponents = calendar.dateComponents([.second], from: startDate)
        }
        
        return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeatPeriod == .never ? false : true)
    }
    
    private func getNotificationContent(contact: Contact, type: ReminderType) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.sound           = UNNotificationSound.default
        content.userInfo        = [
            "contactId": contact.idString
        ]
        
        switch type {
            
        case .birthday:
            content.title           = "Birthday!".localized()
            content.body            = "Today is the birthday of %@".localized(with: contact.name)
        case .beforeBirthday:
            content.title           = "Birthday!".localized()
            content.body            = "Tomorrow is the birthday of %@".localized(with: contact.name)
        case .regular:
            content.title           = "Keep in touch".localized()
            content.body            = "Contact with %@".localized(with: contact.name)
        case .regularHalfYear:
            content.title           = "Keep in touch".localized()
            content.body            = "Contact with %@".localized(with: contact.name)
        }
    
        return content
    }
    
    private func scheduleNotification(for contact: Contact, startDate: Date, type: ReminderType, repeatPeriod: NotificationPeriod, debug: Bool) {
        let trigger = getNotificationTrigger(startDate: startDate, repeatPeriod: repeatPeriod, debug: debug)
        let content = getNotificationContent(contact: contact, type: type)
        
        // Создаем запрос
        let request = UNNotificationRequest(
            identifier: getNotificationIdentifier(for: contact, type: type),
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
        
        center.add(request)
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
    
    func setContactScheduleNotifications(for contact: Contact, debug: Bool = false) {
        let calendar = Calendar.current
        
        // Удаление всех уведомлений
        for reminderType in ReminderType.allCases {
            removeScheduledNotifications(for: contact, type: reminderType)
        }
        
        // Назначение уведомлений согласно настройкам контакта
        if contact.reminderBirthday {
            // В день рождения
            scheduleNotification(for: contact, startDate: contact.birthday, type: .birthday, repeatPeriod: .yearly, debug: debug)
            
            // За день до дня рождения
            if let previousDayBeforeBirthday = calendar.date(byAdding: .day, value: -1, to: contact.birthday) {
                scheduleNotification(for: contact, startDate: previousDayBeforeBirthday, type: .beforeBirthday, repeatPeriod: .yearly, debug: debug)
            }
        }
        
        if contact.reminder {
            if let repeatPeriod = NotificationPeriod(rawValue: contact.reminderRepeat) {
                if repeatPeriod == .halfYearly {
                    // для уведомлений раз в 6 месяцев необходимо задать 2 расписания
                    // текущий месяц
                    scheduleNotification(for: contact, startDate: contact.reminderDate, type: .regular, repeatPeriod: repeatPeriod, debug: debug)
                    // + 6 месяцев
                    if let nextHalfYear = calendar.date(byAdding: .month, value: 6, to: contact.reminderDate) {
                        scheduleNotification(for: contact, startDate: nextHalfYear, type: .regularHalfYear, repeatPeriod: repeatPeriod, debug: debug)
                    }
                } else {
                    scheduleNotification(for: contact, startDate: contact.reminderDate, type: .regular, repeatPeriod: repeatPeriod, debug: debug)
                }
            }
        }
    }
}
