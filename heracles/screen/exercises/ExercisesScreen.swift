//
//  ExercisesScreen.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 13/02/2025.
//

import SwiftUI
import SwiftData

struct ExercisesView: View {
    @Query private var exercises: [Exercise]
    
    var group: MuscleGroup
    
    var body: some View {
        List(exercises.filter {$0.primaryMuscleGroup == group}) { exercise in
            NavigationLink(exercise.name) {
                ExerciseView(exercise: exercise)
            }
        }
        .navigationTitle("\(group.displayName()) Exercises")

    }
}

struct ExercisesScreen: View {
    var body: some View {
        // TODO: split view instead for better support of landscape mode!
        NavigationStack {
            List(MuscleGroup.allCases, id: \.self) { group in
                
                NavigationLink(group.displayName(), destination: ExercisesView(group: group))
            }
            .navigationTitle("Exercises")
        }
    }
}

#Preview {
    ExercisesScreen().modelContainer(for: Exercise.self, inMemory: true) { result in
        do {
            let container = try result.get()
            preloadExercises(container)
        } catch {
            print("Failed to create model container.")
        }
    }
}
