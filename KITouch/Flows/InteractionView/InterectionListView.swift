//
//  InterectionListView.swift
//  KITouch
//
//  Created by Роман Вертячих on 02.07.2025.
//

import SwiftUI

struct InteractionsListView: View {
    let interactions: [Interaction]
    @State private var searchText = ""
    @Environment(\.dismiss) var dismiss
    
    // Фильтрация взаимодействий по поисковому запросу
    var filteredInteractions: [Interaction] {
        if searchText.isEmpty {
            return interactions.sorted { $0.date > $1.date }
        } else {
            return interactions.filter {
                $0.notes.localizedCaseInsensitiveContains(searchText)
            }.sorted { $0.date > $1.date }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Секция с поиском
                Section {
                    SearchBar(text: $searchText)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
                
                // Список взаимодействий
                ForEach(filteredInteractions) { interaction in
                    InteractionCardView(interaction: interaction)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                // Действие удаления
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
                
                // Пустое состояние
                if filteredInteractions.isEmpty {
                    EmptyStateView()
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .navigationTitle("All Interactions")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Кнопка фильтрации
                    Menu {
                        Button("Sort by Date") { /* Сортировка по дате */ }
                        Button("Sort by Type") { /* Сортировка по типу */ }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Компоненты

// Карточка взаимодействия
struct InteractionCardView: View {
    let interaction: Interaction
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Иконка типа взаимодействия
                Image(systemName: interactionTypeIcon)
                    .foregroundColor(interactionTypeColor)
                    .frame(width: 24, height: 24)
                    .background(interactionTypeColor.opacity(0.2))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    // Заголовок с датой
                    Text(interaction.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Тип взаимодействия
//                    if let type = interaction.type {
                        Text(interaction.type .rawValue.capitalized)
                            .font(.caption)
                            .foregroundColor(.accentColor)
//                    }
                }
                
                Spacer()
            }
            
            // Заметки
            if !interaction.notes.isEmpty {
                Text(interaction.notes)
                    .font(.body)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
    
    // Определяем иконку по типу взаимодействия
    private var interactionTypeIcon: String {
        switch interaction.type {
        case .call: return "phone"
        case .meeting: return "person.2"
        case .message: return "message"
        case .email: return "envelope"
        }
    }
    
    // Определяем цвет по типу взаимодействия
    private var interactionTypeColor: Color {
        switch interaction.type {
        case .call: return .green
        case .meeting: return .blue
        case .message: return .orange
        case .email: return .red
        }
    }
}

// Пустое состояние
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.3))
            
            Text("No Interactions Yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Add your first interaction to keep track of your communications")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.vertical, 60)
    }
}

// Кастомная search bar
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Search interactions...", text: $text)
                .padding(8)
                .padding(.horizontal, 24)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if !text.isEmpty {
                            Button(action: {
                                text = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

#Preview {
    InteractionsListView(interactions: [
        Interaction(id: UUID(), date: Date(), notes: "Discussed project timeline", contactId: UUID()),
        Interaction(id: UUID(), date: Date(), notes: "Team sync meeting", contactId: UUID()),
        Interaction(id: UUID(), date: Date(), notes: "Sent project proposal", contactId: UUID()),
        Interaction(id: UUID(), date: Date(), notes: "Quick update about the deadline", contactId: UUID())
        
//        Interaction(id: "1", date: Date(), type: .call, notes: "Discussed project timeline"),
//        Interaction(id: "2", date: Date().addingTimeInterval(-86400), type: .meeting, notes: "Team sync meeting"),
//        Interaction(id: "3", date: Date().addingTimeInterval(-172800), type: .email, notes: "Sent project proposal"),
//        Interaction(id: "4", date: Date().addingTimeInterval(-259200), type: .message, notes: "Quick update about the deadline")
    ])
}
