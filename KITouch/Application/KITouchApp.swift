//
//  KITouchApp.swift
//  KITouch
//
//  Created by Роман Вертячих on 28.05.2025.
//

import SwiftUI

@main
struct KITouchApp: App {
    // MARK: - AppDelegate
    @UIApplicationDelegateAdaptor var appDelegate: CustomAppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContactListView()
        }
    }
}
