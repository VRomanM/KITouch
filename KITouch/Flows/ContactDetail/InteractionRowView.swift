//
//  InteractionRowView.swift
//  KITouch
//
//  Created by Alexey Chanov on 27.06.2025.
//

import SwiftUI

struct InteractionRowView: View {
    let interaction: Interaction
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(interaction.date, format: .dateTime.day().month().year())
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
            }
            
            if !interaction.notes.isEmpty {
                Text(interaction.notes)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    VStack {
        InteractionRowView(interaction: Interaction(date: Date(), notes: "Короткий текст", contactId: UUID()))
        InteractionRowView(interaction: Interaction(date: Date(), notes: "Очень длинный текст, который не поместится в три строки. Очень длинный текст, который не поместится в три строки. Очень длинный текст, который не поместится в три строки. Очень длинный текст, который не поместится в три строки.", contactId: UUID()))
    }
    .padding()
}
