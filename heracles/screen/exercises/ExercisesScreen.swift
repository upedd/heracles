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
    var body: some View {
        // TODO: split view instead for better support of landscape mode!
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        ExerciseList(selectedGroup: nil)
                            .navigationTitle("All Exercises")
                    } label: {
                        
                        Label("All", systemImage: "list.bullet")
                    }
                    NavigationLink {
                        ExerciseList(selectedGroup: nil, recents: true)
                            .navigationTitle("Recent Exercises")
                    } label: {
                        
                        Label("Recent", systemImage: "clock")
                    }
                    NavigationLink {
                        ExerciseList(selectedGroup: nil, customs: true)
                            .navigationTitle("Custom Exercises")
                    } label: {
                        Label("Custom", systemImage: "star")
                    }
                }
                
                Section {
                    ForEach(MuscleGroup.allCases, id: \.self) { group in
                        NavigationLink {
                            ExerciseList(selectedGroup: group)
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
