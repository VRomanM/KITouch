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
            RootView()
                .environment(\.locale, Locale(identifier: "cs_CZ")) //Locale(identifier: "ru_RU"))
        }
    }
}
