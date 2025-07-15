//
//  ContactDetailView.swift
//  KITouch
//
//  Created by Роман Вертячих on 30.05.2025.
//

import SwiftUI

struct ContactDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: ContactDetailViewModel
    @State private var showingNotificationSettings = false
    @State private var showingRefreshAlert = false
    
    private var dateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let minDate = calendar.date(byAdding: .year, value: -120, to: Date())!
        return minDate...Date()
    }
    
    var body: some View {
        ZStack {
            Form {
                // Header Section
                Section {
                    HStack(alignment: .center) {
                        emojiPickerButton
                        VStack(alignment: .leading) {
                            nameTextField
                            HStack {
                                contactTypeMenu
                                if viewModel.contact.contactType == ContactType.other.rawValue {
                                    otherTypeTextField
                                }
                            }
                        }
                        if let _ = viewModel.contact.systemContactId {
                            Button(action: { showingRefreshAlert = true }) {
                                HStack {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                }
                            }
                            .foregroundColor(.accentColor)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Contact Info Section
                Section(header: Text("Contact Info")) {
                    phoneField
                    birthdayPicker
                }
                
                // Social Media Section
                Section(header: Text("Social Media")) {
                    socialMediaGrid
                    Button("Edit") {
                        viewModel.isShowingConnectChannelsListView = true
                    }
                    .foregroundColor(.accentColor)
                }
                
                // Interactions Section
                Section(header: Text("Interactions")) {
                    ForEach(viewModel.interactions.prefix(3)) { interaction in
                        InteractionRowView(interaction: interaction)
                    }
                    
                    if viewModel.interactions.count > 3 {
                        Button("See All %@".localized(with: String(viewModel.interactions.count))) {
                            viewModel.isShowingInteractionListView = true
                        }
                    }
                    
                    Button(action: addInteraction) {
                        Label("Add", systemImage: "plus")
                    }
                    .foregroundColor(.accentColor)
                }
                
                // Notification Section
                Section {
                    if viewModel.isAccessNotifications {
                        Label {
                            Text("The app does not have access to create notifications")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        } icon: {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                        }
                    }
                    Toggle("Birthday", isOn: $viewModel.contact.reminderBirthday)
                    if viewModel.contact.reminderBirthday {
                        Text("You'll be notified one day before the birthday")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    
                    Toggle("Keep in touch", isOn: $viewModel.contact.reminder)
                    
                    if viewModel.contact.reminder {
                        DatePicker("When",
                                   selection: $viewModel.contact.reminderDate,
                                   in: Date()...)
                        
                        Picker("Repeat", selection: $viewModel.contact.reminderRepeat) {
                            ForEach(NotificationPeriod.allCases) { period in
                                Text(period.localizedValue).tag(period)
                            }
                        }
                    }
                    
                } header: {
                    Text("Reminders")
                } footer: {
                    Text("Get reminders to keep in touch")
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $viewModel.isShowingInteractionListView) {
                InteractionsListView(interactions: viewModel.interactions)
            }
            .fullScreenCover(isPresented: $viewModel.isShowingConnectChannelsListView) {
                ConnectChannelsListView(viewModel: ConnectChannelsListViewModel(contactDetalViewModel: viewModel))
            }
            .sheet(isPresented: $viewModel.isShowingNewInteractionView) {
                InteractionView(viewModel: InteractionViewModel(contactId: viewModel.contact.id, contactDetailViewModel: viewModel))
            }
            .sheet(isPresented: $viewModel.isEmojiPickerPresented) {
                EmojiPickerView(selectedEmoji: $viewModel.contact.imageName)
            }
            .onAppear {
                viewModel.checkNotificationAccess()
            }
            .padding(.bottom, 80) // Добавляем отступ снизу для кнопки
            
            // Плавающая кнопка сохранения
            VStack {
                Spacer()
                KITButton(text: "Save".localized(), action: saveAndDismiss)
            }
            .alert("Update Contact".localized(), isPresented: $showingRefreshAlert) {
                Button("Cancel".localized(), role: .cancel) { }
                Button("Update".localized(), role: .destructive) {
                    viewModel.refreshContactFromSystem()
                }
            } message: {
                Text("Contact will be updated from address book".localized())
            }
            .alert("Contact was deleted".localized(), isPresented: $viewModel.showDeletedContactAlert) {
                Button("Keep".localized()) {
                    viewModel.keepDeletedContact()
                }
                Button("Delete".localized(), role: .destructive) {
                    viewModel.deleteContact()
                }
            }
            .onChange(of: viewModel.shouldDismiss) { newValue in
                if newValue {
                    dismiss()
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var emojiPickerButton: some View {
        Button(action: { viewModel.isEmojiPickerPresented = true }) {
            Text(viewModel.contact.imageName)
                .font(.system(size: 48))
                .frame(width: 60, height: 60)
                .background(Color(.systemFill))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
    
    private var nameTextField: some View {
        TextField("Contact name", text: $viewModel.contact.name)
            .font(.title2.bold())
            .textFieldStyle(.plain)
            .disabled(viewModel.contact.isFromSystemContacts)
            .foregroundColor(viewModel.contact.isFromSystemContacts ? .gray : .primary)
    }
    
    private var contactTypeMenu: some View {
        Menu {
            ForEach(ContactType.allCases) { type in
                Button(type.localizedValue) {
                    viewModel.contact.contactType = type.rawValue
                }
            }
        } label: {
            HStack {
                Text(viewModel.contact.contactType.isEmpty ? "Select Type".localized() : viewModel.contact.contactType.localized())
                Image(systemName: "chevron.down")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
    }
    
    private var otherTypeTextField: some View {
        TextField("Enter type", text: $viewModel.contact.customContactType)
            .font(.subheadline)
            .foregroundColor(.secondary)
    }
    
    private var phoneField: some View {
        HStack {
            Image(systemName: "phone")
                .foregroundColor(.secondary)
            TextField("Phone", text: $viewModel.contact.phone)
                .keyboardType(.phonePad)
//                .onChange(of: viewModel.contact.phone) { viewModel.formatPhoneNumber($0) }
//            
//            if !viewModel.isPhoneNumberValid && !viewModel.contact.phone.isEmpty {
//                Image(systemName: "exclamationmark.triangle.fill")
//                    .foregroundColor(.red)
//            }
        }
    }
    
    private var birthdayPicker: some View {
        HStack {
            Image(systemName: "birthday.cake.fill")
                .foregroundColor(.secondary)
            DatePicker("Birthday",
                       selection: $viewModel.contact.birthday,
                      in: dateRange,
                      displayedComponents: .date)
            .labelsHidden()
        }
    }
    
    private var socialMediaGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), alignment: .leading),
                            GridItem(.adaptive(minimum: 120), alignment: .leading)], spacing: 12) {
            ForEach(viewModel.contact.connectChannels) { channel in
                HStack(spacing: 6) {
                    Image(channel.socialMediaType.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 20, height: 20)
                    Text(channel.login)
                        .font(.caption)
                        .lineLimit(1)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(Color(.secondarySystemFill))
                .clipShape(Capsule())
            }
        }
    }
    
    // MARK: - Actions
    
    private func addInteraction() {
        viewModel.isShowingNewInteractionView = true
    }
    
    private func saveAndDismiss() {
        viewModel.saveContactDetail()
        dismiss()
    }
    
    init(contactListViewModel: ContactListViewModel, contact: Contact) {
        _viewModel = StateObject(wrappedValue: ContactDetailViewModel(contactListViewModel: contactListViewModel, contact: contact))
    }
}

#Preview {
    ContactDetailView(contactListViewModel: ContactListViewModel(), contact: Contact())
}

//struct ContactDetailView: View {
//    @Environment(\.dismiss) private var dismiss
//    private let columns: [GridItem] = [GridItem(.flexible(),alignment: .leading),
//                                       GridItem(.flexible(), alignment: .leading)]
//    @StateObject var viewModel: ContactDetailViewModel
//    private let dateRange: ClosedRange<Date> = {
//        let calendar = Calendar.current
//        let minDate = calendar.date(byAdding: .year, value: -120, to: Date())!
//        let maxDate = Date()
//        return minDate...maxDate
//    }()
//    
//    var body: some View {
//        ScrollView {
//            VStack {
//                Button {
//                    viewModel.isEmojiPickerPresented = true
//                } label: {
//                    Text(viewModel.contact.imageName)
//                        .font(.system(size: 40))
//                        .padding()
//                }
//                .sheet(isPresented: $viewModel.isEmojiPickerPresented) {
//                    EmojiPickerView(selectedEmoji: $viewModel.contact.imageName)
//                }
//                VStack(alignment: .leading, spacing: 12) {
//                    TextField("Contact name", text: $viewModel.contact.name) { isEditing in
//                        viewModel.editingElement = isEditing ? .contactName : .nothing
//                    }
//                    .font(.system(.largeTitle, design: .default, weight: .bold))
//                    .foregroundStyle(.mainFont)
//                    .padding(.horizontal, 16)
//                    .padding(.vertical, 12)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 6)
//                            .stroke(viewModel.editingElement == .contactName ? .blue : .gray.opacity(0.3), lineWidth: 1)
//                    )
//                    .submitLabel(.done)
//                    .animation(.bouncy, value: viewModel.editingElement == .contactName)
//                    .padding(.horizontal, 16)
//                    
//                    VStack(alignment: .leading, spacing: 12) {
//                        Menu {
//                            ForEach(ContactType.allCases) { type in
//                                Button(type.localizedValue) {
//                                    viewModel.contact.contactType = type.rawValue
//                                    viewModel.editingElement = .nothing
//                                }
//                            }
//                        } label: {
//                            HStack {
//                                Text(viewModel.contact.contactType.isEmpty ? "Unknown".localized() : viewModel.contact.contactType.localized())
//                                    .foregroundColor(.primary)
//                                Spacer()
//                                Image(systemName: "chevron.down")
//                                    .foregroundColor(.gray)
//                            }
//                        }
//                        .padding(.horizontal, 16)
//                        .padding(.vertical, 12)
//                    }
//                    
//                    if viewModel.contact.contactType == ContactType.other.rawValue {
//                        TextField("Enter the contact type", text: $viewModel.contact.customContactType) { isEditing in
//                            viewModel.editingElement = isEditing ? .contactType : .nothing
//                        }
//                        .padding(.horizontal, 16)
//                        .padding(.vertical, 12)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 6)
//                                .stroke(viewModel.editingElement == .contactType ? .blue : .gray.opacity(0.3), lineWidth: 1)
//                        )
//                        .padding(.horizontal, 16)
//                        .padding(.bottom, 8)
//                    }
//                }
//                
//                Text("Talked \(viewModel.contact.lastMessage, format: .dateTime.day().month().year())")
//                    .font(.title2)
//                    .foregroundColor(.gray)
//                    .padding(.horizontal, 16)
//                
//                VStack(alignment: .leading) {
//                    VStack(alignment: .leading, spacing: 12) {
//                        Text("Phone")
//                            .font(.callout)
//                            .foregroundColor(.gray)
//                        
//                        TextField(viewModel.phonePattern, text: $viewModel.contact.phone) { isEditing in
//                            viewModel.editingElement = isEditing ? .phone : .nothing
//                        }
//                        .fontDesign(.monospaced)
//                        .keyboardType(.phonePad)
//                        .textContentType(.telephoneNumber)
//                        .submitLabel(.done)
//                        .padding(.horizontal, 16)
//                        .padding(.vertical, 12)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 6)
//                                .stroke(viewModel.editingElement == .phone ? .blue : .gray.opacity(0.3), lineWidth: 1)
//                        )
//                        .onSubmit {
//                            viewModel.editingElement = .nothing
//                        }
//                        .onChange(of: viewModel.contact.phone) { newValue in
//                            viewModel.formatPhoneNumber(newValue)
//                            viewModel.editingElement = .nothing
//                        }
//                        
//                        if !viewModel.isPhoneNumberValid && !viewModel.contact.phone.isEmpty {
//                            HStack {
//                                Image(systemName: "exclamationmark.circle.fill")
//                                Text("Enter the correct phone number")
//                            }
//                            .foregroundStyle(.red)
//                            .font(.caption)
//                            .transition(.opacity)
//                        }
//                    }
//                    .animation(.bouncy, value: viewModel.editingElement == .phone)
//                    .padding()
//                    
//                    Divider()
//                    
//                    VStack(alignment: .leading, spacing: 12) {
//                        Text("Birthdate")
//                            .font(.callout)
//                            .foregroundColor(.gray)
//                        
//                        DatePicker(
//                            LocalizedStringKey(""), selection: $viewModel.unwrapBirthday,
//                            in: dateRange,
//                            displayedComponents: .date
//                        ).datePickerStyle(.compact)
//                            .tint(.blue)
//                            .labelsHidden()
//                    }
//                    .padding(.horizontal, 16)
//                    .padding(.bottom, 8)
//                    
//                    Divider()
//                    
//                    HStack {
//                        Text("Soc. media")
//                            .font(.callout)
//                            .foregroundColor(.gray)
//                        Spacer()
//                        Button {
//                            viewModel.isShowingConnectChannelsListView = true
//                        } label: {
//                            Image(systemName: "pencil")
//                                .resizable()
//                                .frame(width: 20, height: 20)
//                        }
//                    }
//                    .padding(.horizontal, 16)
//                    
//                    
//                    LazyVGrid(columns: columns) {
//                        ForEach(viewModel.contact.connectChannels) { connectChannel in
//                            NetworkView(connectChannel: connectChannel)
//                        }
//                    }
//                    .padding(25)
//                    .fullScreenCover(isPresented: $viewModel.isShowingConnectChannelsListView) {
//                    } content: {
//                        ConnectChannelsListView(viewModel: ConnectChannelsListViewModel(contactDetalViewModel: viewModel))
//                    }
//                    
//                    // Добавляем после раздела "Last interaction"
//                    Divider()
//                    
//                    // Новая секция для настроек уведомлений
//                    VStack(alignment: .leading, spacing: 12) {
//                        HStack {
//                            Text("Напоминание")
//                                .font(.callout)
//                                .foregroundColor(.gray)
//                            Spacer()
//                            
//                            Toggle("", isOn: $viewModel.notificationEnabled)
//                                .labelsHidden()
//                                .tint(.blue)
//                        }
//                        .padding(.horizontal, 16)
//                        
//                        if viewModel.notificationEnabled {
//                            Picker("Период", selection: $viewModel.notificationPeriod) {
//                                ForEach(NotificationPeriod.allCases) { period in
//                                    Text(period.localizedValue).tag(period)
//                                }
//                            }
//                            .pickerStyle(.segmented)
//                            .padding(.horizontal, 16)
//                            
//                            DatePicker("Дата напоминания",
//                                       selection: $viewModel.notificationDate,
//                                       in: Date()...,
//                                       displayedComponents: [.date, .hourAndMinute])
//                            .datePickerStyle(.compact)
//                            .padding(.horizontal, 16)
//                            .tint(.blue)
//                        }
//                    }
//                    .animation(.easeInOut, value: viewModel.notificationEnabled)
//
//                    Divider()
//                    
//                    HStack {
//                        Text("Last interaction")
//                            .font(.callout)
//                            .foregroundColor(.gray)
//                        Spacer()
//                        Button {
//                            viewModel.isShowingNewInteractionView = true
//                        } label: {
//                            Image(systemName: "plus")
//                                .resizable()
//                                .frame(width: 20, height: 20)
//                        }
//                    }
//                    .padding(.horizontal, 16)
//                    .padding(.top, 8)
//                    .fullScreenCover(isPresented: $viewModel.isShowingNewInteractionView) {
//                        InteractionView(viewModel: InteractionViewModel(contactId: viewModel.contact.id, contactDetailViewModel: viewModel))
//                    }
//                    
//                    // Таблица взаимодействий
//                    LazyVStack(spacing: 8) {
//                        ForEach(viewModel.interactions) { interaction in
//                            InteractionRowView(interaction: interaction)
//                                .onTapGesture {
//                                    viewModel.selectedInteraction = interaction
//                                    viewModel.isShowingEditInteractionView = true
//                                }
//                                .swipeToDelete {
//                                    viewModel.deleteInteraction(interaction)
//                                }
//                        }
//                    }
//                    .padding(.horizontal, 16)
//                    .padding(.bottom, 16)
//                    .fullScreenCover(isPresented: $viewModel.isShowingEditInteractionView) {
//                        if let interaction = viewModel.selectedInteraction {
//                            InteractionView(viewModel: InteractionViewModel(
//                                interaction: interaction,
//                                contactDetailViewModel: viewModel
//                            ))
//                        }
//                    }
//                }
//            }
//            
//            Spacer()
//        }
//        
//        .dismissKeyboard()
//        .toolbar {
//            ToolbarItem(placement: .topBarTrailing) {
//                Button("Save") {
//                    viewModel.saveContactDetail()
//                    dismiss()
//                }
//            }
//        }
//    }
//    
//    init(contactListViewModel: ContactListViewModel, contact: Contact) {
//        _viewModel = StateObject(wrappedValue: ContactDetailViewModel(contactListViewModel: contactListViewModel, contact: contact))
//    }
//}
//
//struct NetworkView: View {
//    let connectChannel: ConnectChannel
//    
//    var body: some View {
//        HStack {
//            Image(connectChannel.socialMediaType.icon)
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .frame(width: 30, height: 30)
//            Text(connectChannel.login)
//                .font(.footnote)
//                .fontWeight(.light)
//        }
//    }
//}
