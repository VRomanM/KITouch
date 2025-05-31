//
//  ContactDetailView.swift
//  KITouch
//
//  Created by Роман Вертячих on 30.05.2025.
//

import SwiftUI

struct ContactDetailView: View {
    let contact: ContactResponse
    @Binding var isShowingDetailView: Bool
    let columns: [GridItem] = [GridItem(.flexible(),alignment: .leading),
                               GridItem(.flexible(), alignment: .leading)]
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Spacer()
                    Button {
                        isShowingDetailView = false
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color(.label))
                            .imageScale(.large)
                            .frame(width: 44, height: 44)
                    }
                }
                Image(systemName: contact.imageName)
                    .resizable()
                    .frame(width: 250, height: 250)
                    .foregroundStyle(.tint)
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(5)
                    .padding()
                
                Text(contact.name)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                Text(contact.contactType)
                    .font(.title2)
                    .foregroundColor(.gray)
                Text("Общались \(contact.lastMessage, format: .dateTime.day().month().year())")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading) {
                    Text("Телефон")
                        .font(.callout)
                        .foregroundColor(.gray)
                    Text(contact.phone)
                        .font(.body)
                    Divider()
                    Text("Дата рождения")
                        .font(.callout)
                        .foregroundColor(.gray)
                    Text(contact.birthday, format: .dateTime.day().month().year())
                        .font(.body)
                    Divider()
                    Text("Соц. сети")
                        .font(.callout)
                        .foregroundColor(.gray)
                    
                    LazyVGrid(columns: columns) {
                        ForEach(contact.networks, id: \.self) { network in
                            NetworkView(network: network)
                        }
                    }
                }
                .padding(25)
                Spacer()
            }
        }
    }
}

struct NetworkView: View {
    let network: String
    
    var body: some View {
        HStack {
            Image(systemName: "globe")
            Text(network)
        }
    }
}

#Preview {
    ContactDetailView(contact: MocData.sampleContact, isShowingDetailView: .constant(true))
}
