//
//  AppDelegate.swift
//  KITouch
//
//  Created by Роман Вертячих on 21.06.2025.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    
    //MARK: - Private properties
    
    private let store = UserDefaultsStore()
    
    //MARK: - Properties
    
    var pendingContactId: String?
    let notificationManager = NotificationManager.sharedManager
    
    //MARK: - Function
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        notificationManager.requestNotificationAuthorization()
        notificationManager.checkAndRescheduleBirthdayNotifications()
        
//        //test->
//        pendingContactId = "D13F7858-6CAD-42F1-A67B-8E43E3A53F96"
//        store.setString("D13F7858-6CAD-42F1-A67B-8E43E3A53F96", key: .pendingContactId)
//        //<--

        // Обработка случая, когда приложение запущено по нажатию на уведомление
//        if let notificationResponse = launchOptions?[.remoteNotification] as? UNNotificationResponse {
//            handleNotification(response: notificationResponse)
//        }
        
        return true
    }
    
//    func applicationDidBecomeActive(_ application: UIApplication) {
//        // Проверяем, есть ли отложенный контакт для открытия
//        if let contactId = store.getString(key: .pendingContactId) {
//            pendingContactId = contactId
//            store.removeString(key: .pendingContactId)
//        }
//    }
//    
//    func handleNotification(response: UNNotificationResponse) {
//        let userInfo = response.notification.request.content.userInfo
//        if let contactId = userInfo["contactId"] as? String {
//            pendingContactId = contactId
//            // Сохраняем ID контакта для последующей обработки после загрузки приложения
//            store.setString(contactId, key: .pendingContactId)
//        }
//    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let contactId = userInfo["contactId"] as? String,
           let navigation = userInfo["navigation"] as? String,
           navigation == "contactDetail" {
            
            // Отправляем уведомление для навигации
            NotificationCenter.default.post(
                name: NSNotification.Name("OpenContactDetail"),
                object: nil,
                userInfo: ["contactId": contactId]
            )
        }
        completionHandler()
    }
}
