//
//  SettingsView.swift
//  KITouch
//
//  Created by Alexey Chanov on 12.06.2025.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    var body: some View {
        List {
            NavigationLink("About App",
                          destination: Text("KITouch is designed to help you stay connected with friends and colleagues, reminding you to nurture relationships and never miss an important conversation.We believe that strong connections are built on consistent communication, and our mission is to make every interaction meaningful and memorable. With KITouch, every conversation matters.")
                            .padding(.horizontal, 30))

            Button("Leave Feedback") {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
        }
        .navigationTitle("Settings")
    }
}
