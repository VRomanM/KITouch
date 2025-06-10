//
//  KITButton.swift
//  KITouch
//
//  Created by Роман Вертячих on 04.06.2025.
//

import SwiftUI

struct KITButton: View {
    let text: String
    
    var body: some View {
        Text(text.localized())
            .font(.headline)
            .frame(width: 280, height: 50)
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

#Preview {
    KITButton(text: "Test")
}
