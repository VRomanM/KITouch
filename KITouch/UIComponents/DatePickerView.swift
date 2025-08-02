//
//  DatePickerView.swift
//  KITouch
//
//  Created by Роман Вертячих on 01.08.2025.
//

import SwiftUI

struct DatePickerView: View {
    var title: String = ""
    @Binding var date: Date
    @Binding var includeYear: Bool
    @Binding var isPresented: Bool
    let onSave: () -> Void
    
    private let calendar = Calendar.current
    private let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let minDate = calendar.date(byAdding: .year, value: -120, to: Date())!
        return minDate...Date()
    }()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    // Day Picker
                    Picker("Day", selection: Binding(
                        get: { calendar.component(.day, from: date) },
                        set: { updateDate(day: $0) }
                    )) {
                        ForEach(1...31, id: \.self) { day in
                            Text("\(day)").tag(day)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                    
                    // Month Picker
                    Picker("Month", selection: Binding(
                        get: { calendar.component(.month, from: date) },
                        set: { updateDate(month: $0) }
                    )) {
                        ForEach(1...12, id: \.self) { month in
                            Text(calendar.monthSymbols[month - 1]).tag(month)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                    
                    // Year Picker
                    Picker("Year", selection: Binding(
                        get: { includeYear ? calendar.component(.year, from: date) : 0 },
                        set: { newYear in
                            if newYear == 0 {
                                includeYear = false
                            } else {
                                includeYear = true
                                updateDate(year: newYear)
                            }
                        }
                    )) {
                        // Годы
                        ForEach(calendar.component(.year, from: dateRange.lowerBound)...calendar.component(.year, from: dateRange.upperBound), id: \.self) { year in
                            Text("\(year)").tag(year)
                        }
                        // Опция "без года"
                        Text("----").tag(0)
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                }
                .frame(height: 200)
                .padding()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onSave()
                        isPresented = false
                    }
                }
            }
        }
        .presentationDetents([.height(300)]) // Фиксируем высоту sheet
        .presentationDragIndicator(.visible) // Показываем индикатор для drag
    }
    
    private func updateDate(day: Int? = nil, month: Int? = nil, year: Int? = nil) {
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        if let day = day { components.day = day }
        if let month = month { components.month = month }
        if let year = year, year != 0 { components.year = year }
        if let year = year, year == 0 { components.year = 0001 }
        if let newDate = calendar.date(from: components) {
            date = newDate
        }
    }
}

#Preview {
    DatePickerView(date: .constant(Date()), includeYear: .constant(false), isPresented: .constant(true)) { }
}
