//
//  NewInteractionView.swift
//  KITouch
//
//  Created by Alexey Chanov on 27.06.2025.
//

import SwiftUI

struct InteractionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: InteractionViewModel

    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }

                Section("Notes") {
                    TextEditor(text: $viewModel.notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle(viewModel.isEditing ? "Edit" : "New Interaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        viewModel.saveInteraction()
                        dismiss()
                    }
                    .disabled(viewModel.notes.isEmpty)
                }
            }
        }
    }
}
