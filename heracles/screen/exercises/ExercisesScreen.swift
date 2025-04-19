//
//  ExercisesScreen.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 13/02/2025.
//

import SwiftUI
import SwiftData

// TODO: add search bar to main screen
// TODO: hiding exercises?

struct ExercisesScreen: View {
    @Query var exercises: [Exercise]
    @Query var workouts: [Workout]
    @State private var showNewExercise = false
    var body: some View {
        // TODO: split view instead for better support of landscape mode!
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        ExerciseList(selectedGroup: nil, exercises: exercises, workouts: workouts)
                            .navigationTitle("All Exercises")
                    } label: {
                        
                        Label("All", systemImage: "list.bullet")
                    }
                    NavigationLink {
                        ExerciseList(selectedGroup: nil, recents: true, exercises: exercises, workouts: workouts)
                            .navigationTitle("Recent Exercises")
                    } label: {
                        
                        Label("Recent", systemImage: "clock")
                    }
                    NavigationLink {
                        ExerciseList(selectedGroup: nil, customs: true, exercises: exercises, workouts: workouts)
                            .navigationTitle("Custom Exercises")
                    } label: {
                        Label("Custom", systemImage: "star")
                    }
                }
                
                Section {
                    ForEach(MuscleGroup.allCases, id: \.self) { group in
                        NavigationLink {
                            ExerciseList(selectedGroup: group, exercises: exercises, workouts: workouts)
                                .navigationTitle("\(group.rawValue.capitalized) Exercises")
                        } label: {
                            Label {
                                Text(group.rawValue.capitalized)
                            } icon: {
                                Image(systemName: "circle.fill")
                                    .foregroundColor(muscle_group_colors[group])
                                    .imageScale(.medium)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Exercises")
            .toolbar {
                Button {
                    showNewExercise = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showNewExercise) {
                NewExerciseView()
            }
        }
    }
}

#Preview {
    ExercisesScreen().modelContainer(for: Workout.self, inMemory: true) { result in
        do {
            let container = try result.get()
            preloadExercises(container)
            for i in 0..<100 {
                container.mainContext.insert(Workout.sample)
            }
        } catch {
            print("Failed to create model container.")
        }
    }
}
