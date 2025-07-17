//
//  InteractionRowView.swift
//  KITouch
//
//  Created by Alexey Chanov on 27.06.2025.
//

import SwiftUI

struct InteractionRowView: View {
    let interaction: Interaction
    let onTap: (Interaction) -> Void
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            InteractionHeaderView(interaction: interaction)
            InteractionNotesView(notes: interaction.notes)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(backgroundLayer)
        .overlay(borderLayer)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            handleTap()
        }
    }
    
    private var backgroundLayer: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
    
    private var borderLayer: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(interaction.type.color.opacity(isPressed ? 0.3 : 0.1), lineWidth: 1)
    }
    
    private func handleTap() {
        withAnimation {
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                onTap(interaction)
            }
        }
    }
}

// MARK: - Подкомпоненты
private struct InteractionHeaderView: View {
    let interaction: Interaction
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            InteractionIconView(type: interaction.type)
            InteractionInfoView(interaction: interaction)
            Spacer()
            ChevronIndicator()
        }
    }
}

private struct InteractionIconView: View {
    let type: InteractionType
    
    var body: some View {
        Group {
            if case .socialMedia(let socialType, _) = type {
                Image(socialType.icon)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: type.icon)
                    .fontWeight(.medium)
            }
        }
        .frame(width: 20, height: 20)
        .foregroundColor(type.color)
        .padding(8)
        .background(type.color.opacity(0.15))
        .clipShape(Circle())
    }
}

private struct InteractionInfoView: View {
    let interaction: Interaction
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(interaction.type.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(interaction.type.color)
            
            Text(interaction.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

private struct ChevronIndicator: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .font(.caption)
            .foregroundColor(.secondary)
            .opacity(0.6)
    }
}

private struct InteractionNotesView: View {
    let notes: String
    
    var body: some View {
        if !notes.isEmpty {
            Text(notes)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(3)
                .padding(.leading, 48)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        InteractionRowView(
            interaction: Interaction(
                date: Date(),
                notes: "Короткий текст",
                contactId: UUID(),
                type: .call
            ),
            onTap: { _ in }
        )
        
        InteractionRowView(
            interaction: Interaction(
                date: Date(),
                notes: "Общались в Teams про новый проект и обсудили детали будущей встречи",
                contactId: UUID(),
                type: .socialMedia(.teams, "test_Login")
            ),
            onTap: { _ in }
        )
        
        InteractionRowView(
            interaction: Interaction(
                date: Date(),
                notes: "Очень длинный текст, который не поместится в три строки. Очень длинный текст, который не поместится в три строки. Очень длинный текст, который не поместится в три строки.",
                contactId: UUID(),
                type: .message
            ),
            onTap: { _ in }
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
