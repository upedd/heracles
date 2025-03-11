//
//  heraclesApp.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 13/02/2025.
//

import SwiftUI
import SwiftData

@MainActor func preloadExercises(_ container: ModelContainer) {
    do {
            // Check we haven't already added our exercises.
            let descriptor = FetchDescriptor<Exercise>()
            let existingExercises = try container.mainContext.fetchCount(descriptor)
            guard existingExercises == 0 else { return }

            // Load and decode the JSON.
            guard let url = Bundle.main.url(forResource: "minified-exercises", withExtension: "json") else {
                fatalError("Failed to find exercises.json")
            }
        
            let data = try Data(contentsOf: url)
            let file = try JSONDecoder().decode(ExercisesFile.self, from: data)
            // Add all our data to the context.
            for exercise in file.exercises {
                if exercise.images != nil {
                    print("debug")
                }
                container.mainContext.insert(exercise)
            }
        } catch {
            print("Failed to pre-seed database: \(error)")
        }
}

@main
struct heraclesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Workout.self) { result in
            do {
                let container = try result.get()
                preloadExercises(container)
            } catch {
                print("Failed to create model container.")
            }
        }
    }
}
