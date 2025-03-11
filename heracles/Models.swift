import Foundation
import SwiftData
import SwiftUI
enum ExerciseType : String, Codable {
    case weight_reps
    case duration
    case bodyweight_reps
    case assisted_bodyweight
    case weighted_bodyweight
}

enum Equipment : String, Codable, CaseIterable {
    case ez_curl_bar
    case barbell
    case dumbbell
    case exercise_ball
    case medicine_ball
    case kettlebell
    case machine
    case cable
    case foam_roll
    case other
    case bands
}

let equipment_name: [String: Equipment] = [
    "ez curl bar": .ez_curl_bar,
    "barbell": .barbell,
    "dumbbell": .dumbbell,
    "exercise ball": .exercise_ball,
    "medicine ball": .medicine_ball,
    "kettlebell": .kettlebell,
    "machine": .machine,
    "cable": .cable,
    "foam roll": .foam_roll,
    "other": .other,
    "bands": .bands
]

extension Equipment {
    func displayName() -> String {
        for (k, v) in equipment_name {
            if v == self {
                return k.capitalized
            }
        }
        return ""
    }
}

// remove those useless muscle groups

enum Muscle: String, Codable, CaseIterable {
    case forearms
    case abductors
    case adductors
    case middle_back
    case neck
    case biceps
    case shoulders
    case serratus_anterior
    case chest
    case triceps
    case abs
    case calves
    case glutes
    case traps
    case quads
    case hamstrings
    case lats
    case brachialis
    case obliques
    case soleus
    case lower_back
}

enum MuscleGroup: String, Codable, CaseIterable {
    case arms
    case back
    case chest
    case core
    case legs
    case shoulders
}

let muscle_to_group: [Muscle: MuscleGroup] = [
    .forearms: .arms,
    .biceps: .arms,
    .triceps: .arms,
    .brachialis: .arms,
    .abductors: .legs,
    .adductors: .legs,
    .quads: .legs,
    .hamstrings: .legs,
    .calves: .legs,
    .soleus: .legs,
    .middle_back: .back,
    .neck: .back,
    .serratus_anterior: .chest,
    .lats: .back,
    .traps: .back,
    .lower_back: .back,
    .glutes: .legs,
    .abs: .core,
    .obliques: .core,
    .shoulders: .shoulders,
    .chest: .chest
]

let muscle_group_colors: [MuscleGroup: Color] = [
    .arms: .red,
    .back: .orange,
    .chest: .yellow,
    .core: .green,
    .legs: .blue,
    .shoulders: .purple
]

let muscle_name: [(Muscle, String)] = [
    (.forearms, "forearms"),
    (.abductors, "abductors"),
    (.adductors, "adductors"),
    (.middle_back, "middle back"),
    (.neck, "neck"),
    (.biceps, "biceps"),
    (.shoulders, "shoulders"),
    (.serratus_anterior, "serratus anterior"),
    (.chest, "chest"),
    (.triceps, "triceps"),
    (.abs, "abs"),
    (.calves, "calves"),
    (.glutes, "glutes"),
    (.traps, "traps"),
    (.quads, "quads"),
    (.hamstrings, "hamstrings"),
    (.lats, "lats"),
    (.brachialis, "brachialis"),
    (.obliques, "obliques"),
    (.soleus, "soleus"),
    (.lower_back, "lower back")
]

extension Muscle {
    func displayName() -> String {
        for (group, name) in muscle_name {
            if group == self {
                return name.capitalized
            }
        }
        return ""
    }
    
    static func stringToGroup(_ name: String) -> Muscle {
        for (group, group_name) in muscle_name {
            if group_name == name {
                return group
            }
        }
        return .forearms
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
        //case type
        case primary_muscles
        case secondary_muscles
        case instructions
        case video
        case equipment
        case images
    }
    // TODO: get more data!
    
    /*
     Each exercise has the following schema:
     
     category, from categories above
     strength is the general catch-all category for exercises that are sport-agnostic
     name, as a string with no underscores and (url safe) characters
     aliases as a list<string>? for other names of the exercise
     description as a string?
     instructions as a list<string>
     tips as a list<string>?
     equipment as a list<string>
     primary_muscles as a list<string>
     secondary_muscles as a list<string>
     tempo as a string? (3-1-1-0, for example)
     images as a list<string>? of urls
     video as a string? url (embeddable YouTube videos used when possible)
     variation_on as a list<string>?
     Example 1: Close-Grip Incline Bench Press is both a variation on close-grip bench press and also incline bench press)
     Example 2: Zottman Preacher Curl is both a variation on zottman curl and preacher curl
     license_author as a string? (wger-specific: who submitted the exercise online on wger)
     license as a map<string, string>? (wger-specific):
     full_name as a string
     short_name as a string
     url as a string
     
     */
    
    
    
    var name: String
    //var type: ExerciseType
    var primaryMuscles: [Muscle]
    var secondaryMuscles: [Muscle]
    var equipment: [Equipment] = []
    var instructions: [String] = []
    var video: String? = nil
    var images: [String]? = nil
    
    @Relationship(deleteRule: .cascade) var pinnedNotes: [ExerciseNote] = []
    var hidden = false // Hidden exercises are not shown in the exercises list, we use it instead of deleting exercises in case they are used in a workout
    
    init(name: String, type: ExerciseType, primaryMuscleGroup: Muscle, secondaryMuscleGroups: [Muscle] = []) {
        self.name = name
        //self.type = type
        self.primaryMuscles = [primaryMuscleGroup]
        self.secondaryMuscles = secondaryMuscleGroups
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        // self.type = try container.decode(ExerciseType.self, forKey: .type)
        let primaryMuscles = try container.decode([String].self, forKey: .primary_muscles)
        self.primaryMuscles = primaryMuscles.map { Muscle.stringToGroup($0) }
        let secondaryMuscles = try container.decode([String].self, forKey: .secondary_muscles)
        self.secondaryMuscles = secondaryMuscles.map { Muscle.stringToGroup($0) }
        self.instructions = try container.decode([String].self, forKey: .instructions)
        let equipment = try container.decode([String].self, forKey: .equipment)
        self.equipment = equipment.map { equipment_name[$0] ?? nil }.compactMap { $0 }
        self.video = try container.decodeIfPresent(String.self, forKey: .video)
        self.images = try container.decodeIfPresent([String].self, forKey: .images)
        
    }
    
    func encode(to encoder: Encoder) throws {
        // FIXME: broken
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        //try container.encode(type, forKey: .type)
        try container.encode(primaryMuscles, forKey: .primary_muscles)
        try container.encode(secondaryMuscles, forKey: .secondary_muscles)
        try container.encode(instructions, forKey: .instructions)
        try container.encode(video, forKey: .video)
    }
    
    
    static var sample: Exercise {
        let exercises: [Exercise] = [
            Exercise(name: "Bench Press", type: .weight_reps, primaryMuscleGroup: .chest, secondaryMuscleGroups: [.triceps, .shoulders]),
            Exercise(name: "Squat", type: .weight_reps, primaryMuscleGroup: .quads, secondaryMuscleGroups: [.hamstrings, .glutes]),
            Exercise(name: "Pull-ups", type: .bodyweight_reps, primaryMuscleGroup: .lats),
            Exercise(name: "Lat Pulldown", type: .weight_reps, primaryMuscleGroup: .lats, secondaryMuscleGroups: [.biceps]),
            Exercise(name: "Biceps Curl", type: .weight_reps, primaryMuscleGroup: .biceps),
            Exercise(name: "Triceps Pushdown", type: .weight_reps, primaryMuscleGroup: .triceps),
            Exercise(name: "Leg Extension", type: .weight_reps, primaryMuscleGroup: .quads)
        ]
        
        return exercises.randomElement()!
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
    
    
    static var sample: WorkoutSet {
        return WorkoutSet(reps: Int.random(in: 4...15), weight: Double(Int.random(in: 2...12)) * 10.0)
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
    
    static var sample: WorkoutExercise {
        var sets: [WorkoutSet] = []
        for _ in 0..<Int.random(in: 3...6) {
            sets.append(WorkoutSet.sample)
        }
        return WorkoutExercise(exercise: Exercise.sample, sets: sets)
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
    var endDate: Date
    
    init(date: Date = Date.now, name: String = "", duration: TimeInterval = 0.0, notes: String = "", exercises: [WorkoutExercise] = [], endDate: Date = Date.now) {
        self.date = date
        self.duration = duration
        self.name = name
        self.notes = notes
        self.exercises = exercises
        self.endDate = endDate

    }
    
    static var sample: Workout {
        let workout = Workout(date: Date.now.addingTimeInterval(-86400 * Double.random(in: 1...300)), name: "Chest Day", duration: Double.random(in: 1800...5400))
        for _ in 0..<Int.random(in: 4...7) {
            workout.exercises.append(WorkoutExercise.sample)
            workout.exercises.last!.workout = workout
        }
        workout.endDate = workout.date.addingTimeInterval(workout.duration)
        return workout
    }
}

final class ExercisesFile: Codable {
    enum CodingKeys: CodingKey {
        case exercises
    }
    
    var exercises: [Exercise]
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.exercises = try container.decode([Exercise].self, forKey: .exercises)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(exercises, forKey: .exercises)
    }
}
