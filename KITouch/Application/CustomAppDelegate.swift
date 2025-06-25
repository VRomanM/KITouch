//
//  CustomAppDelegate.swift
//  KITouch
//
//  Created by Роман Вертячих on 21.06.2025.
//

import SwiftUI

class CustomAppDelegate: NSObject, UIApplicationDelegate {
        
    //MARK: - Properties
    
    let notificationManager = NotificationManager.sharedManager
    
    //MARK: - Function
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        notificationManager.requestNotificationAuthorization()
                
        return true
    }
}

extension CustomAppDelegate: UNUserNotificationCenterDelegate {
        
    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        // обработка полученного уведомления
        notificationManager.handle(notification: response)
    }
    
    // Необходимо, если уведомления должны отображаться, когда приложение находится на переднем плане
    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.list, .banner, .sound])
    }

}
