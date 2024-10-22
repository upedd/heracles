//
//  models.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 04/10/2024.
//

import SwiftData
import Foundation

@Model
final class Workout {
    var name: String
    var date: Date
    var endDate: Date?
    var duration: Duration?
    var finished: Bool = true // temp: migration
    
    @Relationship(deleteRule: .cascade)
    var exercies = [WorkoutExercise]()
    
    init(name: String, date: Date) {
        self.name = name
        self.date = date
        self.finished = false
    }
    
}

// TODO: should this contain relationship to WorkoutExercises
// TODO: add more fields
@Model
final class Exercise {
    // maybe enum?
    static let muscleGroups = ["Abs", "Biceps", "Calves", "Chest", "Forearms", "Glutes", "Hamstrings", "Lats", "Lower Back", "Upper Back", "Traps", "Triceps", "Other"]
    var name: String
    var instructions = ""
    var targetMuscleGroup = "Other"
    var selection = [String]()
    var youtubeVideoUrl = ""
    
    init(name: String) {
        self.name = name
    }
}


// TODO: rethink naming
// this represents exercised tracked in a workout
// and Exercise represents description of given exercise
@Model
final class WorkoutExercise {
    @Relationship
    var exercise: Exercise?
    @Relationship(deleteRule: .cascade, inverse: \Set.workoutExercise)
    var sets = [Set]()
    
    var expanded = true
    init() {
        
    }
}

@Model
final class Set {
    var label: String
    var reps: Int?
    var weight: Double?
    var completed = false
    var workoutExercise: WorkoutExercise?
    var isWarmup = false
    
    init(label: String, reps: Int? = nil, weight: Double? = nil) {
        self.label = label
        self.reps = reps
        self.weight = weight
    }
}
