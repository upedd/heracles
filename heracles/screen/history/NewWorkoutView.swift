//
//  NewWorkoutView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 12/04/2025.
//

import SwiftUI

// possibly lots of overlapping with ActiveWorkout and WorkoutEditor!



struct NewWorkoutView: View {
    @State var workout: Workout = Workout()
    @State private var showDurationSelector = false
    @State private var isAddingExercises = false
    @State private var editMode = EditMode.active
    @State private var hasCustomDuration = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var suggestedDuration: TimeInterval {
        workout.endDate.timeIntervalSince(workout.date)
    }
    
    @State private var showCancellationWarning = false
    
    init(date: Date? = nil) {
        workout.date = date ?? Date()
        workout.endDate = date ?? Date()
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $workout.name)
                TextField("Notes", text: $workout.notes)
                
            }
            
            Section {
                DatePicker("Start Date", selection: $workout.date)
                DatePicker("End Date", selection: $workout.endDate, in: workout.date...Date.distantFuture)
                
                // Ideally this should be toggle like disclosure group like in reminders app
                HStack {
                    Text("Duration")
                    Spacer()
                    if workout.duration.rounded() != suggestedDuration.rounded() {
                        Button {
                            workout.duration = suggestedDuration
                        } label: {
                            Text("Set \(suggestedDuration.formatted)")
                        }
                        .buttonStyle(.borderless)
                    }
                    
                    
                    Button {
                        showDurationSelector = true
                    } label: {
                        Text(workout.duration.formatted)
                    }.popover(isPresented: $showDurationSelector) {
                        DurationPicker(duration: $workout.duration)
                            .presentationCompactAdaptation(.popover)
                    }
                    .buttonStyle(.bordered)
                    .foregroundStyle(.primary)
                }
            }
            
            Section("Exercises") {
                ForEach(workout.exercises) { exercise in
                    NavigationLink {
                        WorkoutExerciseView(exercise: exercise, active: false)
                    } label: {
                        Text(exercise.exercise.name)
                            
                    }
                }
                .onDelete { indexSet in
                    workout.exercises.remove(atOffsets: indexSet)
                }
                .onMove { indices, newOffset in
                    workout.exercises.move(fromOffsets: indices, toOffset: newOffset)
                }

                Button {
                    isAddingExercises.toggle()
                } label: {
                    Label("Add Exercises", systemImage: "plus")
                }
                .sheet(isPresented: $isAddingExercises) {
                    SelectExercisesView(onDone: { selected in
                        for exercise in selected {
                            workout.exercises.append(WorkoutExercise(exercise: exercise))
                        }
                    })
                }
            }
        }
        .navigationTitle("Log Past Workout")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    modelContext.insert(workout)
                    dismiss()
                } label: {
                    Text("Save")
                        .fontWeight(.bold)
                }
                .disabled(workout.name.isEmpty || workout.exercises.isEmpty)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                // should probably also check if date changed but whatever
                Button {
                    if !workout.name.isEmpty || !workout.notes.isEmpty || !workout.exercises.isEmpty || workout.duration != 0 {
                        showCancellationWarning.toggle()
                    } else {
                        dismiss()
                    }
                } label: {
                    Text("Cancel")
                }
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
        NewWorkoutView()
    }
    .modelContainer(for: Workout.self, inMemory: true) { result in
        do {
            let container = try result.get()
            preloadExercises(container)
        } catch {
            print("Error!")
        }

    }
}
