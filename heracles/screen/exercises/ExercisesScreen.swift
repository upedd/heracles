//
//  ExercisesScreen.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 13/02/2025.
//

import SwiftUI
import SwiftData

// TODO: visual tweaks
// TODO: add search bar
// TODO: custom exercises
// TODO: recent exercises

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
                        ExerciseList(selectedGroup: nil)
                            .navigationTitle("Recent Exercises")
                    } label: {
                        
                        Label("Recent", systemImage: "clock")
                    }
                    NavigationLink {
                        ExerciseList(selectedGroup: nil)
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
                            
                            Image(systemName: "circle.fill")
                                .foregroundColor(muscle_group_colors[group])
                                .imageScale(.small)
                            Text(group.rawValue.capitalized)
                        }
                    }
                }
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
