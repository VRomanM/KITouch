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
                .environment(\.locale, Locale(identifier: "ru_RU"))
        }
    }

    init() {
        CustomNavigationBarAppearance.setup()
    }
}
