//
//  ConnectChannelsListView.swift
//  KITouch
//
//  Created by Роман Вертячих on 02.06.2025.
//

import SwiftUI

struct ConnectChannelsListView: View {
    @StateObject var viewModel: ConnectChannelsListViewModel
    @FocusState private var focusedField: ConnectChannel?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Фон с градиентом
                LinearGradient(gradient: Gradient(colors: [Color(.systemGroupedBackground), Color(.secondarySystemGroupedBackground)]),
                               startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                
                // Основной контент
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach($viewModel.connectChannels) { $channel in
                                ConnectChannelCard(
                                    channel: $channel,
                                    onDelete: {
                                        withAnimation(.smooth) {
                                            viewModel.deleteChannel(channel)
                                        }
                                    }
                                )
                                .id(channel.id)
                                .focused($focusedField, equals: channel)
                                .transition(.slide)
                                
                            }
                            .padding(.horizontal)
                            // Кнопка добавления
                            AddButton {
                                withAnimation {
                                    let newChannel = viewModel.addConnectChannel()
                                    // Прокручиваем к новому элементу после его добавления
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation {
                                            proxy.scrollTo(newChannel.id, anchor: .top)
                                        }
                                    }
                                }
                            }
                            .padding(.top, 8)
                            .padding(.bottom, 80)
                        }
                        .padding(.vertical)
                    }
                    .onChange(of: focusedField) { newValue in
                        // Прокручиваем к выбранному TextField при появлении клавиатуры
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            if let focusedIndex = newValue {
                                withAnimation {
                                    proxy.scrollTo(focusedIndex.id, anchor: .top)
                                }
                            }
                        }
                    }
                }
                // Плавающая кнопка сохранения
                VStack {
                    Spacer()
                    KITButton(text: "Save".localized(), action: viewModel.saveConnectChannels)
                }
            }
            .navigationTitle("Soc. media")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.closeView()
                    }
                    .fontWeight(.medium)
                }
            }
            .dismissKeyboard()
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
                Text("Add")
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
            .navigationTitle("Select soc. media")
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
