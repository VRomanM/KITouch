//
//  SettingsView.swift
//  KITouch
//
//  Created by Alexey Chanov on 12.06.2025.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            NavigationLink("О приложении", destination: Text("Информация о приложении"))
            NavigationLink("Оставить отзыв", destination: Text("Форма для отзыва"))
            NavigationLink("Уведомления", destination: Text("Настройки уведомлений"))
        }
        .navigationTitle("Настройки")
    }
}
