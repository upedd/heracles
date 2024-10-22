//
//  DurationPicker.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 10/10/2024.
//

import SwiftUI

struct TimePickerView: View {
    private let pickerViewTitlePadding: CGFloat = 4.0
    
    let title: String
    let range: ClosedRange<Int>
    let binding: Binding<Int>
    
    var body: some View {
        HStack(spacing: -pickerViewTitlePadding) {
            Picker(title, selection: binding) {
                ForEach(range, id: \.self) { timeIncrement in
                    HStack {
                        Spacer()
                        Text("\(timeIncrement)")
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .pickerStyle(InlinePickerStyle())
            .labelsHidden()
            
            Text(title)
                .fontWeight(.bold)
        }
    }
}

struct DurationPicker: View {
    @Binding var selectedHours: Int
    @Binding var selectedMinutes: Int
    @Binding var selectedSeconds: Int
    
    let hoursRange = 0...23
    let minutesRange = 0...59
    let secondsRange = 0...59
    
    var body: some View {
        HStack(spacing: 0) {
            TimePickerView(title: "hours",
                           range: hoursRange,
                           binding: $selectedHours)
            .frame(minWidth: 0)
                                    .compositingGroup()
                                    .clipped()

            TimePickerView(title: "min",
                           range: minutesRange,
                           binding: $selectedMinutes)
            .frame(minWidth: 0)
                                    .compositingGroup()
                                    .clipped()
            TimePickerView(title: "sec",
                           range: secondsRange,
                           binding: $selectedSeconds)
            .frame(minWidth: 0)
                                    .compositingGroup()
                                    .clipped()
        }
        .padding(.all, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
