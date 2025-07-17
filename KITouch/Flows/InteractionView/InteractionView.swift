//
//  NewInteractionView.swift
//  KITouch
//
//  Created by Alexey Chanov on 27.06.2025.
//

import SwiftUI

// MARK: - Main View
struct InteractionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: InteractionViewModel
    @State private var showingSocialMediaPicker = false
    
    init(viewModel: InteractionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    InteractionDateSection(date: $viewModel.date)
                    InteractionTypeSection(
                        selectedType: $viewModel.selectedTypeSelection,
                        interactionType: $viewModel.selectedInteractionType,
                        availableChannels: viewModel.availableConnectChannels,
                        showingSocialMediaPicker: $showingSocialMediaPicker
                    )
                    InteractionNotesSection(notes: $viewModel.notes, isInitiallyExpanded: !viewModel.isEditing)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle((viewModel.isEditing ? "Edit" : "New interaction").localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .sheet(isPresented: $showingSocialMediaPicker) {
                SocialMediaPickerView(
                    channels: viewModel.availableConnectChannels,
                    selectedType: $viewModel.selectedInteractionType,
                    isPresented: $showingSocialMediaPicker
                )
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Отмена") { dismiss() }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Готово") {
                viewModel.saveInteraction()
                dismiss()
            }
            .disabled(viewModel.notes.isEmpty)
        }
    }
}

// MARK: - Date Section
struct InteractionDateSection: View {
    @Binding var date: Date
    @State private var isExpanded = false
    
    var body: some View {
        ExpandableSection(
            title: "Date".localized(),
            icon: "calendar",
            iconColor: .blue,
            isExpanded: $isExpanded
        ) {
            if isExpanded {
                DatePicker("", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.graphical)
            } else {
                Text(date.formatted(date: .long, time: .omitted))
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
            }
        }
    }
}

// MARK: - Type Section
struct InteractionTypeSection: View {
    @Binding var selectedType: InteractionTypeSelection
    @Binding var interactionType: InteractionType
    let availableChannels: [ConnectChannel]
    @Binding var showingSocialMediaPicker: Bool
    @State private var isExpanded = false
    
    var body: some View {
        ExpandableSection(
            title: "Type".localized(),
            icon: "tag",
            iconColor: .purple,
            isExpanded: $isExpanded
        ) {
            if isExpanded {
                typeSelectionList
            } else {
                selectedTypeView
            }
        }
    }
    
    private var typeSelectionList: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(InteractionTypeSelection.allCases, id: \.self) { type in
                InteractionTypeRow(
                    type: type,
                    selectedType: $selectedType,
                    interactionType: $interactionType,
                    availableChannels: availableChannels,
                    showingSocialMediaPicker: $showingSocialMediaPicker
                )
            }
        }
    }
    
    private var selectedTypeView: some View {
        HStack(spacing: 12) {
            if case .socialMedia(let type, let login) = interactionType,
               let channel = availableChannels.first(where: { $0.socialMediaType == type && $0.login == login }) {
                SocialMediaChannelView(type: type, channels: [channel])
            } else {
                Image(systemName: selectedType.interactionType.icon)
                    .frame(width: 24, height: 24)
                Text(selectedType.rawValue)
            }
        }
        .foregroundColor(.secondary)
        .padding(.leading, 4)
    }
}

// MARK: - Notes Section
struct InteractionNotesSection: View {
    @Binding var notes: String
    @State private var isExpanded: Bool
    
    init(notes: Binding<String>, isInitiallyExpanded: Bool) {
        self._notes = notes
        self._isExpanded = State(initialValue: isInitiallyExpanded)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            Button {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Label("Notes", systemImage: "note.text")
                        .font(.headline)
                        .foregroundColor(.orange)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .foregroundColor(.secondary)
                }
            }
            
            // Content
            if isExpanded {
                ScrollView {
                    TextEditor(text: $notes)
                        .scrollContentBackground(.hidden)
                        .padding(8)
                }
                .frame(height: 150)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            } else {
                Text(notes.isEmpty ? "No notes".localized() : notes)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Helper Views
struct ExpandableSection<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    @Binding var isExpanded: Bool
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Label(title, systemImage: icon)
                        .font(.headline)
                        .foregroundColor(iconColor)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .foregroundColor(.secondary)
                }
            }
            
            content()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct InteractionTypeRow: View {
    let type: InteractionTypeSelection
    @Binding var selectedType: InteractionTypeSelection
    @Binding var interactionType: InteractionType
    let availableChannels: [ConnectChannel]
    @Binding var showingSocialMediaPicker: Bool
    
    var body: some View {
        Button {
            handleTypeSelection()
        } label: {
            HStack(spacing: 12) {
                typeIcon
                typeLabel
                Spacer(minLength: 0)
                checkmark
            }
            .padding(.vertical, 8)
        }
    }
    
    private func handleTypeSelection() {
        withAnimation {
            if type == .socialMedia {
                showingSocialMediaPicker = true
                selectedType = .socialMedia
            } else {
                selectedType = type
                interactionType = type.interactionType
            }
        }
    }
    
    private var typeIcon: some View {
        Group {
            if type == .socialMedia {
                socialMediaIcon
            } else {
                Image(systemName: type.interactionType.icon)
                    .foregroundColor(type.interactionType.color)
                    .frame(width: 24, height: 24)
            }
        }
    }
    
    private var socialMediaIcon: some View {
        Group {
            if case .socialMedia(let socialType, let login) = interactionType,
               let channel = availableChannels.first(where: { $0.socialMediaType == socialType && $0.login == login }) {
                SocialMediaChannelView(type: socialType, channels: [channel])
            } else {
                Image(systemName: "network")
                    .foregroundColor(.purple)
                    .frame(width: 24, height: 24)
            }
        }
    }
    
    private var typeLabel: some View {
        Group {
            if type != .socialMedia || interactionType == type.interactionType {
                Text(type.rawValue)
                    .foregroundColor(.primary)
            }
        }
    }
    
    private var checkmark: some View {
        Group {
            if type == .socialMedia {
                if case .socialMedia = interactionType {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                }
            } else if selectedType == type {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.accentColor)
            }
        }
    }
}

struct SocialMediaChannelView: View {
    let type: SocialMediaType
    let channels: [ConnectChannel]
    
    var body: some View {
        if let channel = channels.first(where: { $0.socialMediaType == type }) {
            HStack {
                Image(type.icon)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 24, height: 24)
                VStack(alignment: .leading) {
                    Text(type.rawValue)
                        .foregroundColor(.primary)
                    Text(channel.login)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct SocialMediaPickerView: View {
    let channels: [ConnectChannel]
    @Binding var selectedType: InteractionType
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List {
                if channels.isEmpty {
                    Text("No social media channels available")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(channels) { channel in
                        Button {
                            selectedType = .socialMedia(channel.socialMediaType, channel.login)
                            isPresented = false
                        } label: {
                            HStack(spacing: 12) {
                                Image(channel.socialMediaType.icon)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 24, height: 24)
                                VStack(alignment: .leading) {
                                    Text(channel.socialMediaType.rawValue)
                                        .foregroundColor(.primary)
                                    Text(channel.login)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer(minLength: 0)
                                if case .socialMedia(let selectedType, let selectedLogin) = selectedType,
                                   selectedType == channel.socialMediaType && selectedLogin == channel.login {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Social Media")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

#Preview {
    let contact = MocData.sampleContact
    return InteractionView(viewModel: InteractionViewModel(contactId: contact.id,
                                                    contactDetailViewModel: ContactDetailViewModel(contactListViewModel: ContactListViewModel(), contact: contact)))
}
