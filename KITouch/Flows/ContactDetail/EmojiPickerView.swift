//
//  EmojiPickerView.swift
//  KITouch
//
//  Created by Роман Вертячих on 30.06.2025.
//

import SwiftUI

struct EmojiPickerView: View {
    @Binding var selectedEmoji: String
    @Environment(\.dismiss) var dismiss
    
    let emojis = ["😀", "😎", "🤩", "😍", "🥳", "🤠", "👻", "🐶", "🦊", "🐵", "🦄", "🌈", "🎮", "⚽️", "🎸", "🍕"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 20) {
                    ForEach(emojis, id: \.self) { emoji in
                        Button {
                            selectedEmoji = emoji
                            dismiss()
                        } label: {
                            Text(emoji)
                                .font(.system(size: 40))
                                .frame(width: 60, height: 60)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Emoji")
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
