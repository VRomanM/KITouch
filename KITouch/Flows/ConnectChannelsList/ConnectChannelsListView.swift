//
//  ConnectChannelsListView.swift
//  KITouch
//
//  Created by Роман Вертячих on 02.06.2025.
//

import SwiftUI

struct ConnectChannelsListView: View {
    @StateObject var viewModel: ConnectChannelsListViewModel
    @State private var showingTypePicker = false
    @State private var editingChannel: ConnectChannel?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Фон с градиентом
                LinearGradient(gradient: Gradient(colors: [Color(.systemGroupedBackground), Color(.secondarySystemGroupedBackground)]),
                               startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                
                // Основной контент
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach($viewModel.connectChannels) { $channel in
                            ConnectChannelCard(
                                channel: $channel,
                                onDelete: { viewModel.deleteChannel(channel) }
                            )
                            .transition(.slide)
                        }
                        .padding(.horizontal)
                        
                        // Кнопка добавления
                        AddButton {
                            withAnimation {
                                viewModel.addConnectChannel()
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 80)
                    }
                    .padding(.vertical)
                }
                
                // Плавающая кнопка сохранения
                VStack {
                    Spacer()
                    SubmitButton(action: viewModel.saveConnectChannels)
                        .padding()
                        .background(Material.ultraThin)
                        .shadow(radius: 10)
                }
            }
            .navigationTitle("Social Connections")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.closeView()
                    }
                    .fontWeight(.medium)
                }
            }
        }
    }
}


// MARK: - Компоненты

struct ConnectChannelCard: View {
    @Binding var channel: ConnectChannel
    var onDelete: () -> Void
    @State private var showingMediaTypePicker = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Иконка соцсети
            Button {
                showingMediaTypePicker = true
            } label: {
                Image(channel.socialMediaType.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .padding(8)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showingMediaTypePicker) {
                MediaTypePickerView(selectedType: $channel.socialMediaType)
                    .presentationDetents([.height(300)])
                    .presentationDragIndicator(.visible)
            }
            
            // Поле ввода
            VStack(alignment: .leading, spacing: 4) {
                Text(channel.socialMediaType.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextField("Username", text: $channel.login)
                    .font(.body.weight(.medium))
            }
            
            Spacer()
            
            // Кнопки действий
            Menu {
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.secondary)
                    .contentShape(Rectangle())
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct AddButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .imageScale(.large)
                Text("Add Connection")
                    .fontWeight(.medium)
            }
            .foregroundColor(.accentColor)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct SubmitButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Save Connections")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.accentColor)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct EditChannelView: View {
    @State var channel: ConnectChannel
    var onSave: (ConnectChannel) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Platform", selection: $channel.socialMediaType) {
                        ForEach(SocialMediaType.allCases) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.inline)
                    
                    TextField("Username", text: $channel.login)
                        .autocorrectionDisabled()
                }
            }
            .navigationTitle("Edit Connection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onSave(channel)
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(channel)
                    }
                    .disabled(channel.login.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

struct MediaTypePickerView: View {
    @Binding var selectedType: SocialMediaType
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(SocialMediaType.allCases, id: \.self) { type in
                Button {
                    selectedType = type
                    dismiss()
                } label: {
                    HStack {
                        Image(type.icon)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 30, height: 30)
                        
                        Text(type.rawValue)
                            .font(.body)
                        Spacer()
                        if selectedType == type {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
            .navigationTitle("Select Platform")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ConnectChannelsListView(viewModel: ConnectChannelsListViewModel(contactDetalViewModel: ContactDetailViewModel(contactListViewModel: ContactListViewModel(), contact: MocData.sampleContact)))
}
