//
//  WorkoutEditorView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 25/02/2025.
//

import SwiftUI

// TODO: merge with active workout view

struct WorkoutEditorView: View {
    @Bindable var workout: Workout
    @State private var name: String
    @State private var notes: String
    @State private var date: Date
    @State private var endDate: Date
    @State private var duration: TimeInterval
    @State private var showDurationSelector = false
    
    @Environment(\.dismiss) private var dismiss
    @State private var showCancellationWarning = false
    
    var suggestedDuration: TimeInterval {
        endDate.timeIntervalSince(date)
    }
    
    init(workout: Workout) {
        self.workout = workout
        self.name = workout.name
        self.notes = workout.notes
        self.date = workout.date
        self.endDate = workout.endDate
        self.duration = workout.duration
    }
        
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                TextField("Notes", text: $notes)
            }
            
            Section {
                // TODO: maybe add seconds precision?
                DatePicker("Start Date", selection: $date)
                DatePicker("End Date", selection: $endDate, in: date...Date.distantFuture)
                HStack {
                    Text("Duration")
                    Spacer()
                    if duration.rounded() != suggestedDuration.rounded() {
                        Button {
                            duration = suggestedDuration
                        } label: {
                            Text("Set \(suggestedDuration.formatted)")
                        }
                        .buttonStyle(.borderless)
                    }
                    
                    
                    Button {
                        showDurationSelector = true
                    } label: {
                        Text(duration.formatted)
                    }.popover(isPresented: $showDurationSelector) {
                        DurationPicker(duration: $duration)
                            .presentationCompactAdaptation(.popover)
                    }
                    .buttonStyle(.bordered)
                    .foregroundStyle(.primary)
                }
            }
        }
        .navigationTitle("Workout Info")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    if name != workout.name || notes != workout.notes || date != workout.date || endDate != workout.endDate || duration != workout.duration {
                        showCancellationWarning = true
                    } else {
                        dismiss()
                    }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    workout.name = name
                    workout.notes = notes
                    workout.date = date
                    workout.endDate = endDate
                    workout.duration = duration
                    dismiss()
                }
                .bold()
                .disabled(name.isEmpty)
            }
        }
        .confirmationDialog("Discard Changes?", isPresented: $showCancellationWarning, titleVisibility: .hidden) {
            Button("Discard Changes", role: .destructive) {
                dismiss()
            }
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutEditorView(workout: Workout.sample)
    }
}
