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
            NavigationLink("About App",
                          destination: Text("App Information"))
            NavigationLink("Leave Feedback",
                          destination: Text("Feedback Form"))
            NavigationLink("Notifications",
                          destination: Text("Notification Settings"))
        }
        .navigationTitle("Settings")
    }
}
