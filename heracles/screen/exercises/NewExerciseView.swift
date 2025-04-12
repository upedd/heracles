//
//  NewExerciseView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 12/04/2025.
//

import SwiftUI

struct NewExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name: String
    @State private var primaryMuscles: [Muscle]
    

    @State private var secondaryMuscles: [Muscle]
    @State private var equipment: [Equipment]
    @State private var instructions: [String]
        
    @State private var exerciseType: ExerciseEditor.ExerciseType
    
    @State private var showCancellationWarning = false
    
    init() {
        self.name = ""
        self.primaryMuscles = []
        self.secondaryMuscles = []
        self.equipment = []
        self.instructions = [""]
        self.exerciseType = .weightAndReps
    }
    
    init(exercise: Exercise) {
        self.name = exercise.name
        self.primaryMuscles = exercise.primaryMuscles
        self.secondaryMuscles = exercise.secondaryMuscles
        self.equipment = exercise.equipment
        self.instructions = exercise.instructions
        if exercise.trackReps && exercise.trackWeight && !exercise.trackDuration && !exercise.trackTime {
            self.exerciseType = .weightAndReps
        } else {
            self.exerciseType = .distanceAndTime // TODO!
        }
            
    }
    
    var body: some View {
        NavigationStack {
            ExerciseEditor(
                name: $name,
                primaryMuscles: $primaryMuscles,
                secondaryMuscles: $secondaryMuscles,
                equipment: $equipment,
                instructions: $instructions,
                exerciseType: $exerciseType
            )
            .navigationTitle("New Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        if !name.isEmpty || !instructions.isEmpty || !primaryMuscles.isEmpty || !secondaryMuscles.isEmpty || !equipment.isEmpty || exerciseType != .weightAndReps {
                            showCancellationWarning.toggle()
                        } else {
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                    
                    Button("Add") {
                        let exercise = Exercise(
                            name: name,
                            primaryMuscles: primaryMuscles,
                            secondaryMuscles: secondaryMuscles,
                        )
                        exercise.equipment = equipment
                        exercise.instructions = instructions.filter {!$0.isEmpty}
                        exercise.custom = true
                        switch exerciseType {
                        case .weightAndReps:
                            exercise.trackReps = true
                            exercise.trackWeight = true
                            exercise.trackDuration = false
                            exercise.trackTime = false
                        case .distanceAndTime:
                            exercise.trackReps = false
                            exercise.trackWeight = false
                            exercise.trackDuration = true
                            exercise.trackTime = true
                        }
                        
                        modelContext.insert(
                            exercise
                        )
                        dismiss()
                    }
                    .fontWeight(.bold)
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
}

#Preview {
    NewExerciseView()
}
