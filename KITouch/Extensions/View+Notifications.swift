//
//  View+Notifications.swift
//  KITouch
//
//  Created by Роман Вертячих on 23.06.2025.
//

import SwiftUI

extension View {
    func onNotification(perform action: @escaping (UNNotificationResponse) -> Void) -> some View {
        modifier(NotificationViewModifier(onNotification: action, handler: NotificationManager.sharedManager))
    }
}
