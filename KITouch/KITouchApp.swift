//
//  KITouchApp.swift
//  KITouch
//
//  Created by Роман Вертячих on 28.05.2025.
//

import SwiftUI

@main
struct KITouchApp: App {
    var body: some Scene {
        WindowGroup {
            ContactListView()
        }
    }

    init() {
        CustomNavigationBarAppearance.setup()
    }
}
