//
//  TimePickerView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 25/02/2025.
//


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
    @Binding var duration: TimeInterval
    
    private var selectedHours: Binding<Int> {
        Binding {
            Int(duration / 3600)
        } set: {
            duration = TimeInterval($0 * 3600 + Int(duration) % 3600)
        }
    }
    
    private var selectedMinutes: Binding<Int> {
        Binding {
            Int(duration / 60) % 60
        } set: {
            duration = TimeInterval(Int(duration) / 3600 * 3600 + $0 * 60 + Int(duration) % 60)
        }
    }
    
    private var selectedSeconds: Binding<Int> {
        Binding {
            Int(duration) % 60
        } set: {
            duration = TimeInterval(Int(duration) / 60 * 60 + $0)
        }
    }
    let hoursRange = 0...23
    let minutesRange = 0...59
    let secondsRange = 0...59
    
    var body: some View {
        HStack(spacing: 0) {
            TimePickerView(title: "hours",
                           range: hoursRange,
                           binding: selectedHours)
            .frame(minWidth: 0)
                                    .compositingGroup()
                                    .clipped()

            TimePickerView(title: "min",
                           range: minutesRange,
                           binding: selectedMinutes)
            .frame(minWidth: 0)
                                    .compositingGroup()
                                    .clipped()
            TimePickerView(title: "sec",
                           range: secondsRange,
                           binding: selectedSeconds)
            .frame(minWidth: 0)
                                    .compositingGroup()
                                    .clipped()
        }
        .padding(.all, 32)
        //.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
