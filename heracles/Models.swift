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
// TODO: empty equipment case
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
class Barbell {
    var weight: Double
    var label: String
    
    init(weight: Double, label: String) {
        self.weight = weight
        self.label = label
    }
}

let defaultBarbells: [Barbell] = [
    Barbell(weight: 20, label: "Standard"),
    Barbell(weight: 15, label: "Women"),
    Barbell(weight: 10, label: "EZ Curl"),
    Barbell(weight: 20, label: "Trap Bar"),
    
]


enum PlateColor: String, Codable, CaseIterable {
    case red
    case blue
    case yellow
    case green
    case white
    case black
    case gray
}

extension PlateColor {
    func getAsColor() -> Color {
        switch self {
        case .red:
            return Color.red
        case .blue:
            return Color.blue
        case .yellow:
            return Color.yellow
        case .green:
            return Color.green
        case .white:
            return Color.white
        case .black:
            return Color.black
        case .gray:
            return Color.gray
        }
    }
}

@Model
class Plate {
    var weight: Double
    var color: PlateColor
    var width: CGFloat
    var height: CGFloat
    var count: Int
    
    init(weight: Double, color: PlateColor, width: CGFloat, height: CGFloat, count: Int = 20) {
        self.weight = weight
        self.color = color
        self.width = width
        self.height = height
        self.count = count
    }
}

let defaultPlates: [Plate] = [
    Plate(weight: 25, color: .red, width: 27, height: 450),
    Plate(weight: 20, color: .blue, width: 20, height: 450),
    Plate(weight: 15, color: .yellow, width: 19, height: 400),
    Plate(weight: 10, color: .green, width: 19, height: 325),
    Plate(weight: 5, color: .white, width: 20, height: 228),
    Plate(weight: 2.5, color: .black, width: 15, height: 190),
    Plate(weight: 1.25, color: .gray, width: 12, height: 160),
    Plate(weight: 0.5, color: .gray, width: 8, height: 134),
    Plate(weight: 0.25, color: .gray, width: 7, height: 112)
]

@MainActor func preloadBarbells(_ container: ModelContainer) {
    do {
            // Check we haven't already added our exercises.
            let descriptor = FetchDescriptor<Barbell>()
            let existingBarbells = try container.mainContext.fetchCount(descriptor)
            guard existingBarbells == 0 else { return }

            for barbell in defaultBarbells {
                container.mainContext.insert(barbell)
            }
        } catch {
            print("Failed to pre-seed database: \(error)")
        }
}

@MainActor func preloadPlates(_ container: ModelContainer) {
    do {
            // Check we haven't already added our exercises.
            let descriptor = FetchDescriptor<Plate>()
            let existingPlates = try container.mainContext.fetchCount(descriptor)
            guard existingPlates == 0 else { return }
        
            for plate in defaultPlates {
                container.mainContext.insert(plate)
            }
        } catch {
            print("Failed to pre-seed database: \(error)")
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
        case track_reps
        case track_weight
        case track_time
        case track_distance
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
    var trackReps = true
    var trackWeight = true
    var trackDuration = false
    var trackTime = false
    var custom = false
    
    @Relationship(deleteRule: .cascade) var pinnedNotes: [ExerciseNote] = []
    var hidden = false // Hidden exercises are not shown in the exercises list, we use it instead of deleting exercises in case they are used in a workout
    
    init(name: String, type: ExerciseType, primaryMuscleGroup: Muscle, secondaryMuscleGroups: [Muscle] = []) {
        self.name = name
        //self.type = type
        self.primaryMuscles = [primaryMuscleGroup]
        self.secondaryMuscles = secondaryMuscleGroups
    }
    init(name: String, primaryMuscles: [Muscle], secondaryMuscles: [Muscle]) {
        self.name = name
        //self.type = type
        self.primaryMuscles = primaryMuscles
        self.secondaryMuscles = secondaryMuscles
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
        self.trackReps = try container.decodeIfPresent(Bool.self, forKey: .track_reps) ?? true
        self.trackWeight = try container.decodeIfPresent(Bool.self, forKey: .track_weight) ?? true
        self.trackDuration = try container.decodeIfPresent(Bool.self, forKey: .track_time) ?? false
        self.trackTime = try container.decodeIfPresent(Bool.self, forKey: .track_distance) ?? false
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

extension Exercise {
    // Order matters here, should be the same as WorkoutExerciseSet fields order
    var fields: [WorkoutExerciseSetField] {
        var fields: [WorkoutExerciseSetField] = []
        
        if trackTime {
            fields.append(.distance)
        }
        if trackWeight {
            fields.append(.weight)
        }
        if trackDuration {
            fields.append(.minutes)
            fields.append(.seconds)
        }
        if trackReps {
            fields.append(.reps)
        }
        return fields
        
    }
}

let rpe_to_descriptions = [
    10.0: ("Maximal effort", "No reserve remaining. Unsustainable. Inability to continue beyond current exertion."),
    9.5: ("Near-maximal effort"," Almost no reserve. Only a brief continuation is possible."),
    9.0: ("Extremely hard", "Requires maximal focus. Sustainable only for very short durations."),
    8.5: ("Very high effort", "Strong fatigue present. Difficult to speak. Short-term maintenance possible."),
    8.0: ("Hard effort", "Sustainable for several minutes. Breathing is labored. Talking is limited."),
    7.5: ("Moderately hard", "Requires concentration. Noticeable fatigue. Speech limited to short phrases."),
    7.0: ("Steady, challenging effort", "Controlled breathing. Can speak in sentences. Sustainable with effort."),
    6.5: ("Moderate effort", "Breathing slightly elevated. Comfortable yet purposeful pace. Sustainable over time.")
]

let rpe_to_display = [
    10: "10",
    9.5: "9.5",
    9: "9",
    8.5: "8.5",
    8: "8",
    7.5: "7.5",
    7: "7",
    6.5: "6.5",
]

@Model
final class WorkoutSet {
    var reps: Int?
    var weight: Double?
    var time: TimeInterval?
    var distance: Double?
    var RPE: Double? = nil
    var completed = false
    var type = SetType.working
    var order: Int
    
    init(order: Int, reps: Int? = nil, weight: Double? = nil, time: TimeInterval? = nil, distance: Double? = nil) {
        self.reps = reps
        self.weight = weight
        self.time = time
        self.distance = distance
        self.order = order
    }
    var formatted: String {
        // TODO: better formatting!
        // f.e. for running intervals https://www.newintervaltraining.com/iaaf-standardised-sessions-www-newintervaltraining-com.pdf
        
        var output = ""
        if let distance {
            output += "\(distance.formatted()) km "
        }
        if let time {
            let minutes = Int(time) / 60
            let seconds = Int(time) % 60
            output += "\(minutes):\(seconds) "
        }
        
        if let weight {
            output += "\(weight.formatted()) kg "
        }
        
        if let reps {
            output += "× \(reps) "
        }
        if let RPE {
            output += "RPE \(rpe_to_display[RPE]!)"
        }
        return output
    }
    
    static var sample: WorkoutSet {
        return WorkoutSet(order: 0, reps: Int.random(in: 4...15), weight: Double(Int.random(in: 2...12)) * 10.0)
    }
}

// TODO: fix all errors that are caused by reusing workout exercise here!
// TODO: prebuilt workout templates
@Model
final class WorkoutTemplate {
    var name: String
    var exercises: [WorkoutExercise]
    var order: Int
    init(order: Int, name: String, exercises: [WorkoutExercise]) {
        self.order = order
        self.name = name
        self.exercises = exercises
    }
    
    static var sample: WorkoutTemplate {
        var exercises = [WorkoutExercise]()
        for _ in 0..<Int.random(in: 4...7) {
            exercises.append(WorkoutExercise.sample)
        }
        var templateName = ["Chest Day", "Leg Day", "Back Day", "Shoulder Day", "Arm Day", "Upper Workout", "Lower Workout", "Full Body 1", "Full Body 2", "Full Body 3"].randomElement()!
        return WorkoutTemplate(order: 0, name: templateName, exercises: exercises)
    }
}

var workoutTemplatesSampleData: [(name: String, exercises: [(name: String, sets: Int, repsInSet: Int)])] = [
    (
        name: "Upper Body Power",
        exercises: [
            (name: "Barbell Bench Press", sets: 4, repsInSet: 8),
            (name: "Bent Over Barbell Row", sets: 4, repsInSet: 8),
            (name: "Seated Dumbbell Press", sets: 3, repsInSet: 10),
            (name: "Pullups", sets: 3, repsInSet: 10),
            (name: "Dumbbell Flyes", sets: 3, repsInSet: 12)
        ]
    ),
    (
        name: "Lower Body Strength",
        exercises: [
            (name: "Barbell Squat", sets: 5, repsInSet: 5),
            (name: "Romanian Deadlift", sets: 4, repsInSet: 8),
            (name: "Leg Press", sets: 3, repsInSet: 10),
            (name: "Seated Leg Curl", sets: 3, repsInSet: 12)
        ]
    ),
    (
        name: "Push Workout",
        exercises: [
            (name: "Standing Military Press", sets: 4, repsInSet: 8),
            (name: "Incline Dumbbell Press", sets: 4, repsInSet: 10),
            (name: "Dips (Chest Focus)", sets: 3, repsInSet: 12),
            (name: "Triceps Pushdown", sets: 3, repsInSet: 15),
            (name: "Side Lateral Raise", sets: 3, repsInSet: 15)
        ]
    ),
    (
        name: "Pull Workout",
        exercises: [
            (name: "Barbell Deadlift", sets: 4, repsInSet: 6),
            (name: "Seated Cable Rows", sets: 4, repsInSet: 10),
            (name: "Full Range-Of-Motion Lat Pulldown", sets: 3, repsInSet: 12),
            (name: "Barbell Curl", sets: 3, repsInSet: 12),
            (name: "Face Pull", sets: 3, repsInSet: 15)
        ]
    ),
    (
        name: "Leg Day",
        exercises: [
            (name: "Front Barbell Squat", sets: 4, repsInSet: 8),
            (name: "Barbell Walking Lunge", sets: 3, repsInSet: 10),
            (name: "Leg Extensions", sets: 3, repsInSet: 12),
            (name: "Lying Leg Curls", sets: 3, repsInSet: 12),
            (name: "Standing Barbell Calf Raise", sets: 4, repsInSet: 15)
        ]
    ),
    (
        name: "Full Body Basic",
        exercises: [
            (name: "Barbell Squat", sets: 4, repsInSet: 8),
            (name: "Barbell Bench Press", sets: 4, repsInSet: 8),
            (name: "Barbell Deadlift", sets: 4, repsInSet: 6)
        ]
    ),
    (
        name: "Chest Focus",
        exercises: [
            (name: "Barbell Bench Press", sets: 5, repsInSet: 5),
            (name: "Incline Dumbbell Press", sets: 4, repsInSet: 8),
            (name: "Decline Dumbbell Flyes", sets: 3, repsInSet: 10),
            (name: "Cable Crossover", sets: 3, repsInSet: 12),
            (name: "Dips (Chest Focus)", sets: 3, repsInSet: 10)
        ]
    ),
    (
        name: "Back Development",
        exercises: [
            (name: "Barbell Deadlift", sets: 4, repsInSet: 6),
            (name: "Bent Over Barbell Row", sets: 4, repsInSet: 8),
            (name: "Seated Cable Rows", sets: 3, repsInSet: 10),
            (name: "Wide-Grip Lat Pulldown", sets: 3, repsInSet: 12),
            (name: "Face Pull", sets: 3, repsInSet: 15),
            (name: "Hyperextensions (Back Extensions)", sets: 3, repsInSet: 12)
        ]
    ),
    (
        name: "Shoulder Builder",
        exercises: [
            (name: "Seated Dumbbell Press", sets: 4, repsInSet: 8),
            (name: "Arnold Dumbbell Press", sets: 3, repsInSet: 10),
            (name: "Side Lateral Raise", sets: 3, repsInSet: 12),
            (name: "Front Dumbbell Raise", sets: 3, repsInSet: 12),
            (name: "Reverse Flyes", sets: 3, repsInSet: 12),
            (name: "Barbell Shrug", sets: 3, repsInSet: 15)
        ]
    ),
    (
        name: "Arm Day",
        exercises: [
            (name: "Close-Grip Barbell Bench Press", sets: 4, repsInSet: 8),
            (name: "Barbell Curl", sets: 4, repsInSet: 10),
            (name: "EZ-Bar Skullcrusher", sets: 3, repsInSet: 12),
            (name: "Hammer Curl", sets: 3, repsInSet: 12),
            (name: "Triceps Pushdown", sets: 3, repsInSet: 15),
            (name: "Concentration Curls", sets: 3, repsInSet: 15)
        ]
    ),
    (
        name: "Power Lower Body",
        exercises: [
            (name: "Barbell Squat", sets: 5, repsInSet: 5),
            (name: "Barbell Deadlift", sets: 4, repsInSet: 5),
            (name: "Power Clean", sets: 4, repsInSet: 5),
            (name: "Barbell Walking Lunge", sets: 3, repsInSet: 8)
        ]
    ),
    (
        name: "Core Strength",
        exercises: [
            (name: "Plank", sets: 3, repsInSet: 30),
            (name: "Hanging Leg Raise", sets: 3, repsInSet: 12),
            (name: "Russian Twist", sets: 3, repsInSet: 15),
            (name: "Ab Roller", sets: 3, repsInSet: 10),
            (name: "Cable Crunch", sets: 3, repsInSet: 15),
            (name: "Side Bridge", sets: 3, repsInSet: 30),
            (name: "Decline Crunch", sets: 3, repsInSet: 15),
            (name: "Mountain Climbers", sets: 3, repsInSet: 20)
        ]
    ),
    (
        name: "Beginner Full Body",
        exercises: [
            (name: "Barbell Squat", sets: 3, repsInSet: 10),
            (name: "Barbell Bench Press", sets: 3, repsInSet: 10),
            (name: "Wide-Grip Lat Pulldown", sets: 3, repsInSet: 10),
            (name: "Dumbbell Shoulder Press", sets: 3, repsInSet: 10),
            (name: "Barbell Curl", sets: 2, repsInSet: 12),
            (name: "Triceps Pushdown", sets: 2, repsInSet: 12),
            (name: "Front Leg Raises", sets: 2, repsInSet: 15)
        ]
    ),
    (
        name: "Strength Upper Body",
        exercises: [
            (name: "Barbell Bench Press", sets: 5, repsInSet: 5),
            (name: "Bent Over Barbell Row", sets: 5, repsInSet: 5),
            (name: "Standing Military Press", sets: 3, repsInSet: 8),
            (name: "Weighted Pull Ups", sets: 3, repsInSet: 8),
            (name: "Dips (Triceps Focus)", sets: 3, repsInSet: 8)
        ]
    ),
    (
        name: "Quad Focus",
        exercises: [
            (name: "Barbell Squat", sets: 4, repsInSet: 8),
            (name: "Leg Press", sets: 4, repsInSet: 10),
            (name: "Hack Squat", sets: 3, repsInSet: 12),
            (name: "Leg Extensions", sets: 3, repsInSet: 15)
        ]
    ),
    (
        name: "Hamstring Focus",
        exercises: [
            (name: "Romanian Deadlift", sets: 4, repsInSet: 8),
            (name: "Lying Leg Curls", sets: 4, repsInSet: 10),
            (name: "Good Morning", sets: 3, repsInSet: 12),
            (name: "Glute Ham Raise", sets: 3, repsInSet: 12)
        ]
    ),
    (
        name: "Chest and Back",
        exercises: [
            (name: "Barbell Bench Press", sets: 4, repsInSet: 8),
            (name: "Bent Over Barbell Row", sets: 4, repsInSet: 8),
            (name: "Incline Dumbbell Press", sets: 3, repsInSet: 10),
            (name: "Wide-Grip Lat Pulldown", sets: 3, repsInSet: 10),
            (name: "Cable Crossover", sets: 3, repsInSet: 12),
            (name: "Seated Cable Rows", sets: 3, repsInSet: 12)
        ]
    ),
    (
        name: "Shoulders and Arms",
        exercises: [
            (name: "Seated Dumbbell Press", sets: 4, repsInSet: 8),
            (name: "Side Lateral Raise", sets: 3, repsInSet: 12),
            (name: "Close-Grip Barbell Bench Press", sets: 4, repsInSet: 8),
            (name: "Barbell Curl", sets: 3, repsInSet: 10),
            (name: "Triceps Pushdown", sets: 3, repsInSet: 12),
            (name: "Hammer Curl", sets: 3, repsInSet: 12)
        ]
    ),
    (
        name: "Explosive Power",
        exercises: [
            (name: "Power Clean", sets: 5, repsInSet: 3),
            (name: "Box Jump (Multiple Response)", sets: 4, repsInSet: 5),
            (name: "Push Press", sets: 4, repsInSet: 5),
            (name: "Weighted Jump Squat", sets: 3, repsInSet: 8),
            (name: "Medicine Ball Chest Pass", sets: 3, repsInSet: 8)
        ]
    ),
    (
        name: "Minimalist Strength",
        exercises: [
            (name: "Barbell Squat", sets: 5, repsInSet: 5),
            (name: "Barbell Bench Press", sets: 5, repsInSet: 5),
            (name: "Barbell Deadlift", sets: 5, repsInSet: 5),
            (name: "Pullups", sets: 5, repsInSet: 5),
            (name: "Dips (Triceps Focus)", sets: 5, repsInSet: 5)
        ]
    )
]

@MainActor func preloadWorkoutTemplates(_ container: ModelContainer) {
    do {
            // Check we haven't already added our exercises.
            let descriptor = FetchDescriptor<WorkoutTemplate>()
            let existingWorkoutTemplates = try container.mainContext.fetchCount(descriptor)
            guard existingWorkoutTemplates == 0 else { return }
            preloadExercises(container)
            var idx = 0
            for (name, exercises) in workoutTemplatesSampleData {
                let template = WorkoutTemplate(order: idx, name: name, exercises: [])
                var workoutExercises: [WorkoutExercise] = []
                for (exerciseName, sets, repsInSet) in exercises {
                    let exerciseDescriptor = FetchDescriptor<Exercise>(predicate: #Predicate { $0.name == exerciseName })
                    let exercise = try container.mainContext.fetch(exerciseDescriptor)
                    if let firstExercise = exercise.first {
                        let sets = (0..<sets).map { idx in
                            WorkoutSet(order: idx, reps: repsInSet, weight: 0)
                        }
                        let workoutExercise = WorkoutExercise(exercise: firstExercise, order: workoutExercises.count, sets: sets)
                        workoutExercise.template = template
                        workoutExercises.append(workoutExercise)
                    } else {
                        print("Exercise \(exerciseName) not found in database")
                    }
                    
                }
                template.exercises = workoutExercises
                idx += 1
                container.mainContext.insert(template)
            }
        } catch {
            print("Failed to pre-seed database: \(error)")
        }
}
@Model
final class WorkoutExercise {
    var exercise: Exercise
    @Relationship(deleteRule: .cascade) var sets: [WorkoutSet]
    var workout: Workout?
    var template: WorkoutTemplate?
    var order: Int
    
    init(exercise: Exercise, order: Int, sets: [WorkoutSet] = []) {
        self.exercise = exercise
        self.sets = sets
        self.order = order
    }
    
    static var sample: WorkoutExercise {
        var sets: [WorkoutSet] = []
        for _ in 0..<Int.random(in: 3...6) {
            sets.append(WorkoutSet.sample)
        }
        return WorkoutExercise(exercise: Exercise.sample, order: 0, sets: sets)
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
