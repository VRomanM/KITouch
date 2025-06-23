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
        
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
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
