//
//  NewInteractionView.swift
//  KITouch
//
//  Created by Alexey Chanov on 27.06.2025.
//

import SwiftUI

struct NewInteractionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: NewInteractionViewModel

    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker("Дата", selection: $viewModel.date, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }

                Section("Заметки") {
                    TextEditor(text: $viewModel.notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Новое взаимодействие")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
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
    }
}
