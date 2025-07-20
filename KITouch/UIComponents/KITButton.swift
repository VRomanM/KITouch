//
//  KITButton.swift
//  KITouch
//
//  Created by Роман Вертячих on 04.06.2025.
//

import SwiftUI

struct KITButton: View {
    let text: String
    var background: Color = Color.accentColor
    var action: () -> Void


    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(background)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .padding()
        .background(Material.ultraThin)
        .shadow(radius: 10)
    }
}

#Preview {
    KITButton(text: "Test", action: {})
}
