//
//  ContactDetailView.swift
//  KITouch
//
//  Created by Роман Вертячих on 30.05.2025.
//

import SwiftUI

struct ContactDetailView: View {
    @Environment(\.dismiss) private var dismiss

    private let columns: [GridItem] = [GridItem(.flexible(),alignment: .leading),
                               GridItem(.flexible(), alignment: .leading)]
    @StateObject var viewModel: ContactDetailViewModel

    private let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let minDate = calendar.date(byAdding: .year, value: -120, to: Date())!
        let maxDate = Date()
        return minDate...maxDate
    }()
    
    
    var body: some View {
        ScrollView {
            VStack {
                Image(systemName: viewModel.contact.imageName)
                    .resizable()
                    .frame(width: 250, height: 250)
                    .foregroundStyle(.tint)
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(5)
                    .padding()
                
                VStack(alignment: .leading, spacing: 12) {
                    TextField("Contact name", text: $viewModel.contact.name) { isEditing in
                        viewModel.editingElement = isEditing ? .contactName : .nothing
                    }
                    .font(.system(.largeTitle, design: .default, weight: .bold))
                    .foregroundStyle(.mainFont)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(viewModel.editingElement == .contactName ? .blue : .gray.opacity(0.3), lineWidth: 1)
                    )
                    .submitLabel(.done)
                }
                .animation(.bouncy, value: viewModel.editingElement == .contactName)
                .padding(.horizontal, 16)
                
                VStack(alignment: .leading, spacing: 12) {
                    Menu {
                        ForEach(ContactType.allCases) { type in
                            Button(type.localizedValue) {
                                viewModel.contact.contactType = type.rawValue
                                viewModel.editingElement = .nothing
                            }
                        }
                    }
                    label: {
                        HStack {
                            Text(NSLocalizedString(viewModel.contact.contactType.isEmpty ? "Unknown" : viewModel.contact.contactType, comment: ""))
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    
                    if viewModel.contact.contactType == ContactType.other.rawValue {
                        TextField("Enter the contact type", text: $viewModel.contact.customContactType) { isEditing in
                            viewModel.editingElement = isEditing ? .contactType : .nothing
                        }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(viewModel.editingElement == .contactType ? .blue : .gray.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                
                Text("Talked \(viewModel.contact.lastMessage, format: .dateTime.day().month().year())")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Phone")
                            .font(.callout)
                            .foregroundColor(.gray)
                        
                        TextField(viewModel.phonePattern, text: $viewModel.contact.phone) { isEditing in
                            viewModel.editingElement = isEditing ? .phone : .nothing
                        }
                        .fontDesign(.monospaced)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                        .submitLabel(.done)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(viewModel.editingElement == .phone ? .blue : .gray.opacity(0.3), lineWidth: 1)
                        )
                        .onSubmit {
                            viewModel.editingElement = .nothing
                        }
                        .onChange(of: viewModel.contact.phone) { newValue in
                            viewModel.formatPhoneNumber(newValue)
                            viewModel.editingElement = .nothing
                        }
                        
                        if !viewModel.isPhoneNumberValid && !viewModel.contact.phone.isEmpty {
                            HStack {
                                Image(systemName: "exclamationmark.circle.fill")
                                Text("Enter the correct phone number")
                            }
                            .foregroundStyle(.red)
                            .font(.caption)
                            .transition(.opacity)
                        }
                    }
                    .animation(.bouncy, value: viewModel.editingElement == .phone)
                    .padding()
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Birthdate")
                            .font(.callout)
                            .foregroundColor(.gray)
                        
                        DatePicker(
                            LocalizedStringKey(""), selection: $viewModel.unwrapBirthday,
                            in: dateRange,
                            displayedComponents: .date
                        ).datePickerStyle(.compact)
                            .tint(.blue)
                            .labelsHidden()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    
                    Divider()
                    HStack {
                        Text("Soc. media")
                            .font(.callout)
                            .foregroundColor(.gray)
                        Spacer()
                        Button {
                            viewModel.isShowingConnectChannelsListView = true
                        } label: {
                            Image(systemName: "pencil")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                    }
                    LazyVGrid(columns: columns) {
                        ForEach(viewModel.contact.connectChannels) { connectChannel in
                            NetworkView(connectChannel: connectChannel)
                        }
                    }
                }
                .padding(25)
                .fullScreenCover(isPresented: $viewModel.isShowingConnectChannelsListView) {}
                content: {
                    ConnectChannelsListView(viewModel: ConnectChannelsListViewModel(contactDetalViewModel: viewModel))
                }
                Spacer()
            }
        }
        .dismissKeyboard()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    viewModel.saveContactDetail()
                    dismiss()
                }
            }
        }
    }
    
    init(contactListViewModel: ContactListViewModel, contact: Contact) {
        _viewModel = StateObject(wrappedValue: ContactDetailViewModel(contactListViewModel: contactListViewModel, contact: contact))
    }
}

struct NetworkView: View {
    let connectChannel: ConnectChannel
    
    var body: some View {
        HStack {
            Image(connectChannel.socialMediaType.icon)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 30, height: 30)
            Text(connectChannel.login)
                .font(.footnote)
                .fontWeight(.light)
        }
    }
}

extension View {
    func dismissKeyboard() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }
}

#Preview {
    ContactDetailView(contactListViewModel: ContactListViewModel(), contact: Contact())
}
