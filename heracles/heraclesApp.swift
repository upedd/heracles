//
//  heraclesApp.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 13/02/2025.
//

import SwiftUI
import SwiftData
import ObservableDefaults

@MainActor func preloadExercises(_ container: ModelContainer) {
    do {
            // Check we haven't already added our exercises.
            let descriptor = FetchDescriptor<Exercise>()
            let existingExercises = try container.mainContext.fetchCount(descriptor)
            guard existingExercises == 0 else { return }

            // Load and decode the JSON.
            guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json") else {
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

enum WeightUnit : String, Codable, CaseIterable{
    case kilograms
    case pounds
}

enum DistanceUnit : String, Codable, CaseIterable {
    case kilometers
    case miles
}

extension WeightUnit {
    func short() -> String {
        // return short name for unit
        switch self {
            case .kilograms:
            return "kg"
        case .pounds:
            return "lbs"
        }
    }
}

extension DistanceUnit {
    func short() -> String {
        switch self {
        case .kilometers:
            return "km"
        case .miles:
            return "mi"
        }
    }
}

@ObservableDefaults(autoInit: false)
class Settings {
    init() {
        observerStarter()
    }
    var weightUnit: WeightUnit = Locale.current.measurementSystem == .metric ? .kilograms : .pounds
    var distanceUnit: DistanceUnit = Locale.current.measurementSystem == .metric ? .kilometers : .miles
}

@main
struct heraclesApp: App {
    //@State private var settings = Settings()
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Workout.self, Barbell.self, Plate.self, WorkoutTemplate.self]) { result in
            do {
                let container = try result.get()
                preloadExercises(container)
                preloadBarbells(container)
                preloadPlates(container)
                preloadWorkoutTemplates(container)
            } catch {
                print("Failed to create model container.")
            }
        }
        .environment(Settings())
    }
}
