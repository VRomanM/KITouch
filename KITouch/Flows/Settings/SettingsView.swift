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
            NavigationLink(NSLocalizedString("About App", comment: ""),
                          destination: Text(NSLocalizedString("App Information", comment: "")))
            NavigationLink(NSLocalizedString("Leave Feedback", comment: ""),
                          destination: Text(NSLocalizedString("Feedback Form", comment: "")))
            NavigationLink(NSLocalizedString("Notifications", comment: ""),
                          destination: Text(NSLocalizedString("Notification Settings", comment: "")))
        }
        .navigationTitle(NSLocalizedString("Settings", comment: ""))
    }
}
