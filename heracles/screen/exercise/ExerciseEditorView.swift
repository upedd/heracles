//
//  ExerciseEditorView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 12/04/2025.
//

import SwiftUI

// TODO: notes editing!

struct ExerciseEditorView: View {
    @Bindable var exercise: Exercise
    @Binding var isEditing: Bool
    
    @State private var name = ""
    @State private var primaryMuscles: [Muscle] = []
    @State private var secondaryMuscles: [Muscle] = []
    @State private var equipment: [Equipment] = []
    @State private var instructions: [String] = [""]
    @State private var exerciseType: ExerciseEditor.ExerciseType = .weightAndReps

    @State private var showCancellationWarning = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ExerciseEditor(
            name: $name,
            primaryMuscles: $primaryMuscles,
            secondaryMuscles: $secondaryMuscles,
            equipment: $equipment,
            instructions: $instructions,
            exerciseType: $exerciseType
        )
        .navigationTitle("Edit Exercise")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    var typesMatch = false
                    if exerciseType == .weightAndReps && exercise.trackReps && exercise.trackWeight && !exercise.trackTime && !exercise.trackDuration {
                        typesMatch = true
                    }
                    if exerciseType == .distanceAndTime && !exercise.trackWeight && !exercise.trackReps && exercise.trackTime && exercise.trackDuration {
                        typesMatch = true
                    }
                    if name == exercise.name && primaryMuscles == exercise.primaryMuscles && secondaryMuscles == exercise.secondaryMuscles && equipment == exercise.equipment && instructions == exercise.instructions && typesMatch {
                        isEditing = false
                    } else {
                        showCancellationWarning.toggle()
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    exercise.name = name
                    exercise.primaryMuscles = primaryMuscles
                    exercise.secondaryMuscles = secondaryMuscles
                    exercise.equipment = equipment
                    exercise.instructions = instructions
                    exercise.trackReps = exerciseType == .weightAndReps
                    exercise.trackWeight = exerciseType == .weightAndReps
                    exercise.trackTime = exerciseType == .distanceAndTime
                    exercise.trackDuration = exerciseType == .distanceAndTime
                    isEditing = false
                }
                .fontWeight(.bold)
                .disabled(name.isEmpty)
            }
        }
        .confirmationDialog("Discard Changes?", isPresented: $showCancellationWarning, titleVisibility: .hidden) {
            Button("Discard Changes", role: .destructive) {
                isEditing = false
            }
        }
        .onAppear {
            name = exercise.name
            primaryMuscles = exercise.primaryMuscles
            secondaryMuscles = exercise.secondaryMuscles
            equipment = exercise.equipment
            if exercise.instructions.isEmpty {
                instructions = [""]
            } else {
                instructions = exercise.instructions
            }
            if exercise.trackReps && exercise.trackWeight && !exercise.trackTime && !exercise.trackDuration {
                exerciseType = .weightAndReps
            }
            if !exercise.trackWeight && !exercise.trackReps && exercise.trackTime && exercise.trackDuration {
                exerciseType = .distanceAndTime
            }
        }
    }
}

#Preview {
    ExerciseEditorView(exercise: Exercise.sample, isEditing: .constant(true))
        
}
