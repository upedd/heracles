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
    @State private var showDurationSelector = false
    @State private var isAddingExercises = false
    @State private var editMode = EditMode.active
    
    var suggestedDuration: TimeInterval {
        workout.endDate.timeIntervalSince(workout.date)
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $workout.name)
                TextField("Notes", text: $workout.notes)
                
            }
            
            Section {
                // TODO: maybe add seconds precision?
                DatePicker("Start Date", selection: $workout.date)
                DatePicker("End Date", selection: $workout.endDate, in: workout.date...Date.distantFuture)
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
            
            Section {
                ForEach(workout.exercises) { exercise in
                    WorkoutExerciseLink(workoutExercise: exercise)
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
        .environment(\.editMode, $editMode)
    }
}

#Preview {
    NavigationStack {
        WorkoutEditorView(workout: Workout.sample)
    }
}
