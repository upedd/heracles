import Foundation
import SwiftData

enum ExerciseType : String, Codable {
    case weight_reps
    case duration
    case bodyweight_reps
    case assisted_bodyweight
    case weighted_bodyweight
}

enum MuscleGroup: String, Codable, CaseIterable {
    case chest
    case back
    case front_delts
    case side_delts
    case rear_delts
    case biceps
    case triceps
    case forearms
    case lats
    case upper_back
    case lower_back
    case abs
    case calves
    case quads
    case hamstrings
    case glutes
    case abductors
    case adductors
    case other
}

extension MuscleGroup {
    func displayName() -> String {
        switch (self) {
        case .front_delts:
                return "Front Delts"
            case .side_delts:
                return "Side Delts"
            case .rear_delts:
                return "Rear Delts"
            case .upper_back:
                return "Upper Back"
            case .lower_back:
                return "Lower Back"
        default:
            return self.rawValue.capitalized
        }
    }
}

@Model
class ExerciseNote {
    var text: String
    var pinned = false

    init(text: String) {
        self.text = text
    }
}

@Model
class Exercise: Codable {
    enum CodingKeys: CodingKey {
        case name
        case type
        case primaryMuscleGroup
        case secondaryMuscleGroups
        case instructions
        case youtubeVideoURL
    }
    
    var name: String
    var type: ExerciseType
    var primaryMuscleGroup: MuscleGroup
    var secondaryMuscleGroups: [MuscleGroup]
    var instructions: String? = nil
    var youtubeVideoURL: String? = nil
    @Relationship(deleteRule: .cascade) var pinnedNotes: [ExerciseNote] = []
    var hidden = false // Hidden exercises are not shown in the exercises list, we use it instead of deleting exercises in case they are used in a workout

    init(name: String, type: ExerciseType, primaryMuscleGroup: MuscleGroup, secondaryMuscleGroups: [MuscleGroup] = []) {
        self.name = name
        self.type = type
        self.primaryMuscleGroup = primaryMuscleGroup
        self.secondaryMuscleGroups = secondaryMuscleGroups
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.type = try container.decode(ExerciseType.self, forKey: .type)
        self.primaryMuscleGroup = try container.decode(MuscleGroup.self, forKey: .primaryMuscleGroup)
        self.secondaryMuscleGroups = try container.decode([MuscleGroup].self, forKey: .secondaryMuscleGroups)
        self.instructions = try container.decode(String.self, forKey: .instructions)
        self.youtubeVideoURL = try container.decode(String.self, forKey: .youtubeVideoURL)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        try container.encode(primaryMuscleGroup, forKey: .primaryMuscleGroup)
        try container.encode(secondaryMuscleGroups, forKey: .secondaryMuscleGroups)
        try container.encode(instructions, forKey: .instructions)
        try container.encode(youtubeVideoURL, forKey: .youtubeVideoURL)
    }

}

enum SetType : String, CaseIterable, Codable {
    case working = "Working"
    case warmup = "Warm-up"
    case cooldown = "Cooldown"
}

@Model
final class WorkoutSet {
    var reps: Int?
    var weight: Double?
    var time: TimeInterval?
    var completed = false
    var type = SetType.working
    
    init(reps: Int? = nil, weight: Double? = nil, time: TimeInterval? = nil) {
        self.reps = reps
        self.weight = weight
        self.time = time
    }
}
@Model
final class WorkoutExercise {
    var exercise: Exercise
    @Relationship(deleteRule: .cascade) var sets: [WorkoutSet]
    var workout: Workout?
    
    init(exercise: Exercise, sets: [WorkoutSet] = []) {
        self.exercise = exercise
        self.sets = sets
    }
}


@Model
final class Workout {
    var date: Date
    var name: String
    var notes: String
    var duration: TimeInterval
    @Relationship(inverse: \WorkoutExercise.workout) var exercises: [WorkoutExercise]
    var active: Bool = false
    var paused: Bool = false
    var pausedTime: TimeInterval = 0.0
    
    init(date: Date = Date.now, name: String = "", duration: TimeInterval = 0.0, notes: String = "", exercises: [WorkoutExercise] = []) {
        self.date = date
        self.duration = duration
        self.name = name
        self.notes = notes
        self.exercises = exercises
    }
}

