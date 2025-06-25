//
//  NotificationViewModifier.swift
//  KITouch
//
//  Created by Роман Вертячих on 23.06.2025.
//

import SwiftUI

struct NotificationViewModifier: ViewModifier {
    
    // MARK: - Private Properties
    private let onNotification: (UNNotificationResponse) -> Void
    
    // MARK: - Initializers
    init(onNotification: @escaping (UNNotificationResponse) -> Void, handler: NotificationManager) {
        self.onNotification = onNotification
    }
    
    // MARK: - Body
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationManager.sharedManager.$latestNotification) { notification in
                guard let notification else { return }
                onNotification(notification)
            }
    }
}
