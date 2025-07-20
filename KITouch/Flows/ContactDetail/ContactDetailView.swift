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

    // Добавляем состояния для секций
    @State private var isInteractionExpanded    = true
    @State private var isNotificationExpanded   = false
    @State private var isSocialMediaExpanded    = false

    private var dateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let minDate = calendar.date(byAdding: .year, value: -120, to: Date())!
        return minDate...Date()
    }

    // Computed property для проверки номера телефона
    private var hasPhoneNumber: Bool {
        !viewModel.contact.phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
                Section {
                    DisclosureGroup(
                        isExpanded: $isSocialMediaExpanded,
                        content: {
                            socialMediaGrid
                            Button("Edit") {
                                viewModel.isShowingConnectChannelsListView = true
                            }
                            .foregroundColor(.accentColor)
                        },
                        label: {
                            Text("Social Media")
                                .foregroundColor(.primary)
                        }
                    )
                }

                // Interactions Section
                if !viewModel.contact.isNewContact {
                    Section {
                        DisclosureGroup(
                            isExpanded: $isInteractionExpanded,
                            content: {
                                ForEach(viewModel.interactions.prefix(2)) { interaction in
                                    Button {
                                        viewModel.selectedInteraction = interaction
                                        viewModel.isEditingInteraction = true
                                    } label: {
                                        InteractionRowView(
                                            interaction: interaction,
                                            onTap: { interaction in
                                                viewModel.selectedInteraction = interaction
                                                viewModel.isEditingInteraction = true
                                            }
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            viewModel.deleteInteraction(interaction)
                                        } label: {
                                            Label("", systemImage: "trash")
                                        }
                                    }
                                    .padding(.horizontal, -16)
                                }

                                if viewModel.interactions.count > 2 {
                                    Button("See All %@".localized(with: String(viewModel.interactions.count))) {
                                        viewModel.isShowingInteractionListView = true
                                    }
                                }

                                Button(action: addInteraction) {
                                    Label("Add", systemImage: "plus")
                                }
                                .foregroundColor(.accentColor)
                            },
                            label: {
                                Text("Interactions")
                                    .foregroundColor(.primary)
                            }
                        )
                    }
                }

                // Notification Section
                Section {
                    DisclosureGroup(
                        isExpanded: $isNotificationExpanded,
                        content: {
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
                                HStack(spacing: 8) {
                                    if viewModel.contact.reminderBeforeBirthday {
                                        Picker("Notify for", selection: $viewModel.contact.reminderCountDayBeforeBirthday) {
                                            ForEach(1...15, id: \.self) { day in
                                                Text("\(day)").tag(day)
                                            }
                                        }
                                        .pickerStyle(.menu)
                                        .fixedSize()
                                        Text("дн.")
                                            .foregroundColor(.secondary)
                                            .font(.subheadline)
                                    } else {
                                        Text("In advance")
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Toggle("", isOn: $viewModel.contact.reminderBeforeBirthday)
                                }
                                if viewModel.contact.reminderBeforeBirthday {
                                    Text("You'll be notified at 10:00 %@ day(s) before the birthday and on birthday".localized(with: String(viewModel.contact.reminderCountDayBeforeBirthday)))
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("You'll be notified at 10:00 on birthday")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
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
                        },
                        label: {
                            Text("Reminders")
                                .foregroundColor(.primary)
                        }
                    )
                } footer: {
                    Text("Get reminders to keep in touch")
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveAndDismiss()
                    }
                }
            }
            .fullScreenCover(isPresented: $viewModel.isShowingInteractionListView) {
                InteractionsListView(
                    interactions: viewModel.interactions,
                    contactDetailViewModel: viewModel
                )
            }
            .fullScreenCover(isPresented: $viewModel.isShowingConnectChannelsListView) {
                ConnectChannelsListView(viewModel: ConnectChannelsListViewModel(contactDetalViewModel: viewModel))
            }
            .sheet(isPresented: $viewModel.isShowingNewInteractionView) {
                InteractionView(viewModel:
                                    InteractionViewModel(contactId: viewModel.contact.id,
                                                         contactDetailViewModel: viewModel)
                )
            }
            .sheet(item: $viewModel.selectedInteraction) { interaction in
                InteractionView(
                    viewModel: InteractionViewModel(
                        interaction: interaction,
                        contactDetailViewModel: viewModel
                    )
                )
            }
            .sheet(isPresented: $viewModel.isEmojiPickerPresented) {
                EmojiPickerView(selectedEmoji: $viewModel.contact.imageName)
            }
            .onAppear {
                viewModel.checkNotificationAccess()
            }
            .padding(.bottom, hasPhoneNumber ? 80 : 0)

            // Плавающая кнопка звонка (показывается только если есть номер)
            if hasPhoneNumber {
                VStack {
                    Spacer()
                    if viewModel.contact.isNewContact {
                        KITButton(text: "Save".localized(), action: saveAndDismiss)
                    } else {
                        KITButton(text: "Call".localized(), background: Color.green, action: makeCall)
                    }
                }
            }
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
            Button {
                makeCall()
            } label: {
                Image(systemName: "phone.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            }
            .disabled(!hasPhoneNumber)
            .opacity(hasPhoneNumber ? 1.0 : 0.5)

            TextField("Phone", text: $viewModel.contact.phone)
                .keyboardType(.phonePad)
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

    private func makeCall() {
        let phoneNumber = viewModel.contact.phone.filter { $0.isNumber }
        if let url = URL(string: "tel://\(phoneNumber)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    init(contactListViewModel: ContactListViewModel, isShowingNewInteractionView: Bool, contact: Contact) {
        var model = ContactDetailViewModel(contactListViewModel: contactListViewModel, contact: contact)
        model.isShowingNewInteractionView = isShowingNewInteractionView
        _viewModel = StateObject(wrappedValue: model)
    }
}


#Preview {
    ContactDetailView(contactListViewModel: ContactListViewModel(), isShowingNewInteractionView: false, contact: Contact())
}
