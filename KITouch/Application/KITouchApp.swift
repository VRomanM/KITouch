//
//  KITouchApp.swift
//  KITouch
//
//  Created by Роман Вертячих on 28.05.2025.
//

import SwiftUI

@main
struct KITouchApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContactListView()
        }
    }
}
