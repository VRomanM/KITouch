//
//  InterectionListView.swift
//  KITouch
//
//  Created by Роман Вертячих on 02.07.2025.
//

import SwiftUI

struct InteractionsListView: View {
    let interactions: [Interaction]
    let contactDetailViewModel: ContactDetailViewModel // Добавляем ViewModel как параметр
    @State private var searchText = ""
    @State private var sortOrder: SortOrder = .date
    @State private var selectedInteraction: Interaction?
    @Environment(\.dismiss) var dismiss
    
    enum SortOrder {
        case date
        case type
    }
    
    // Фильтрация и сортировка взаимодействий
    var filteredAndSortedInteractions: [Interaction] {
        let filtered = searchText.isEmpty ? interactions : interactions.filter {
            $0.notes.localizedCaseInsensitiveContains(searchText)
        }
        
        switch sortOrder {
        case .date:
            return filtered.sorted { $0.date > $1.date }
        case .type:
            return filtered.sorted { lhs, rhs in
                let lhsType = String(describing: lhs.type)
                let rhsType = String(describing: rhs.type)
                if lhsType == rhsType {
                    return lhs.date > rhs.date
                }
                return lhsType < rhsType
            }
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
                ForEach(filteredAndSortedInteractions) { interaction in
                    InteractionCardView(
                        interaction: interaction,
                        onTap: { interaction in
                            selectedInteraction = interaction
                        }
                    )
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
                if filteredAndSortedInteractions.isEmpty {
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
                    Menu {
                        Button {
                            sortOrder = .date
                        } label: {
                            Label("Sort by Date", systemImage: "calendar")
                        }
                        Button {
                            sortOrder = .type
                        } label: {
                            Label("Sort by Type", systemImage: "tag")
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(item: $selectedInteraction) { interaction in
                InteractionView(
                    viewModel: InteractionViewModel(
                        interaction: interaction,
                        contactDetailViewModel: contactDetailViewModel
                    )
                )
            }
        }
    }
}

// MARK: - Компоненты

// Карточка взаимодействия
struct InteractionCardView: View {
    let interaction: Interaction
    let onTap: (Interaction) -> Void
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Иконка типа взаимодействия
                if case .socialMedia(let type, _) = interaction.type {
                    Image(type.icon)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 24, height: 24)
                        .background(interaction.type.color.opacity(0.2))
                        .clipShape(Circle())
                } else {
                    Image(systemName: interaction.type.icon)
                        .foregroundColor(interaction.type.color)
                        .frame(width: 24, height: 24)
                        .background(interaction.type.color.opacity(0.2))
                        .clipShape(Circle())
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    // Заголовок с датой
                    Text(interaction.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Тип взаимодействия
                    Text(interaction.type.title)
                        .font(.caption)
                        .foregroundColor(interaction.type.color)
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
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            withAnimation {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                    onTap(interaction)
                }
            }
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
            
            Text("Add your interactions to keep track of your communications")
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
            TextField("Search", text: $text)
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
    let contactListViewModel = ContactListViewModel()
    let contactDetailViewModel = ContactDetailViewModel(
        contactListViewModel: contactListViewModel,
        contact: MocData.sampleContact
    )
    
    InteractionsListView(
        interactions: [
            Interaction(
                id: UUID(),
                date: Date(),
                notes: "Discussed project timeline",
                contactId: MocData.sampleContact.id,
                type: .call
            ),
            Interaction(
                id: UUID(),
                date: Date().addingTimeInterval(-86400),
                notes: "Team sync meeting",
                contactId: MocData.sampleContact.id,
                type: .meeting
            ),
            Interaction(
                id: UUID(),
                date: Date().addingTimeInterval(-172800),
                notes: "Sent project proposal",
                contactId: MocData.sampleContact.id,
                type: .message
            ),
            Interaction(
                id: UUID(),
                date: Date().addingTimeInterval(-259200),
                notes: "Quick update about the deadline",
                contactId: MocData.sampleContact.id,
                type: .message
            ),
            Interaction(
                id: UUID(),
                date: Date().addingTimeInterval(-345600),
                notes: "Discussed in Teams",
                contactId: MocData.sampleContact.id,
                type: .socialMedia(.teams, "Test_Login")
            ),
            Interaction(
                id: UUID(),
                date: Date().addingTimeInterval(-345600),
                notes: "Discussed in VK",
                contactId: MocData.sampleContact.id,
                type: .socialMedia(.instagram, "Test_Login")
            )
        ],
        contactDetailViewModel: contactDetailViewModel
    )
}
