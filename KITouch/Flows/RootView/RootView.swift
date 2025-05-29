//
//  RootView.swift
//  KITouch
//
//  Created by Роман Вертячих on 28.05.2025.
//

import SwiftUI

struct RootView: View {
    let date: Date = {
        var components = DateComponents()
        components.day = 7
        components.month = 10
        components.year = 2024
        return Calendar.current.date(from: components) ?? Date()
    }()
    var body: some View {
        List {
            ContactView(name: "Элина Петрова", contactType: "Коллега", imageName: "globe", lastMessage: date, countMessages: 3)
                .padding(.vertical, 10)
            ContactView(name: "Элина Петрова", contactType: "Коллега", imageName: "globe", lastMessage: date, countMessages: 3)
        }
            .listStyle(.plain)
    }
}

#Preview {
    RootView()
}

struct ContactView: View {
    let name: String
    let contactType: String
    let imageName: String
    let lastMessage: Date
    let countMessages: Int
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundStyle(.tint)
                .aspectRatio(contentMode: .fit)
            VStack(alignment: .leading) {
                Spacer()
                Text(name)
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(contactType)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                Spacer()
                HStack {
                    Text("Общались \(lastMessage, format: .dateTime.day().month().year())")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                    Spacer()
                    Text("\(countMessages)")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }
                Spacer()
            }
        }
    }
}
