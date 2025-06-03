//
//  ContactListView.swift
//  KiTouch
//
//  Created by Роман Вертячих on 28.05.2025.
//

import SwiftUI

struct ContactListView: View {
    @StateObject var viewModel = ContactListViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Поисковое поле
                HStack {
                    TextField("Search", text: $viewModel.searchQuery)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                    // Кнопка отмены, появляется только если есть текст
                    if !viewModel.searchQuery.isEmpty {
                        Button(action: {
                            viewModel.searchQuery = ""
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }) {
                            Text("Cancel")
                                .foregroundColor(.white)
                                .padding(.trailing, 10)
                        }
                    }
                }
                .padding(10)
                .background(.blue)

                List {
                    ForEach(viewModel.filteredContacts) { contact in
                        Section {
                            ContactView(contact: contact)
                                .onTapGesture {
                                    viewModel.selectedContact = contact
                                }
                        }
                    }
                }
                .listStyle(.grouped)
                .listSectionSpacing(.compact)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {}) {
                            Image(systemName: "line.horizontal.3")
                                .foregroundColor(.white)
                        }
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {}) {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            // Поддержка детального экрана
            .fullScreenCover(isPresented: $viewModel.isShowingDetailView) {
                ContactDetailView(contact: viewModel.selectedContact ?? MocData.sampleContact,
                                  isShowingDetailView: $viewModel.isShowingDetailView)
            }
        }
    }
}

#Preview {
    ContactListView()
}

struct ContactView: View {
    let contact: ContactResponse
    
    var body: some View {
        HStack {
            Image(systemName: contact.imageName)
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundStyle(.tint)
                .aspectRatio(contentMode: .fit)
            VStack(alignment: .leading) {
                Spacer()
                Text(contact.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(contact.contactType)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                Spacer()
                HStack {
                    Text("Talked \(contact.lastMessage, format: .dateTime.day().month().year())")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                    Spacer()
                    Text("\(contact.countMessages)")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }
                Spacer()
            }
        }
    }
}
