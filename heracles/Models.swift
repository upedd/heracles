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

@MainActor func preloadBarbells(_ container: ModelContainer, force: Bool = false) {
    do {
            // Check we haven't already added our exercises.
            let descriptor = FetchDescriptor<Barbell>()
            let existingBarbells = try container.mainContext.fetchCount(descriptor)
            guard existingBarbells == 0 && !force else { return }

            for barbell in defaultBarbells {
                container.mainContext.insert(barbell)
            }
        } catch {
            print("Failed to pre-seed database: \(error)")
        }
}

@MainActor func preloadPlates(_ container: ModelContainer, force: Bool = false) {
    do {
            // Check we haven't already added our exercises.
            let descriptor = FetchDescriptor<Plate>()
            let existingPlates = try container.mainContext.fetchCount(descriptor)
            guard existingPlates == 0 && !force else { return }
        
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
    var id = UUID() // hopefully fixes random crashes!
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
    func formatted(settings: Settings) -> String {
        // TODO: better formatting!
        // f.e. for running intervals https://www.newintervaltraining.com/iaaf-standardised-sessions-www-newintervaltraining-com.pdf
        
        var output = ""
        if let distance {
            output += "\(distance.formatted()) \(settings.distanceUnit.short()) "
        }
        if let time {
            let minutes = Int(time) / 60
            let seconds = Int(time) % 60
            output += "\(minutes):\(seconds) "
        }
        
        if let weight {
            output += "\(weight.formatted()) \(settings.weightUnit.short()) "
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
    var date = Date.now // TODO: should sync to workout date
    
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

// ai generated code!
@MainActor func preloadDemoData(_ container: ModelContainer) {
    do {
        // Check if we have already added demo data
        let workoutDescriptor = FetchDescriptor<Workout>()
        let existingWorkouts = try container.mainContext.fetchCount(workoutDescriptor)
        guard existingWorkouts == 0 else { return }
        
        // Make sure we have exercise templates and equipment loaded
        preloadWorkoutTemplates(container)
        preloadBarbells(container)
        preloadPlates(container)
        
        // Get all workout templates
        let templateDescriptor = FetchDescriptor<WorkoutTemplate>()
        let templates = try container.mainContext.fetch(templateDescriptor)
        
        guard !templates.isEmpty else {
            print("No workout templates available to create demo data")
            return
        }
        
        // Get current date and calculate the start date (365 days ago)
        let currentDate = Date()
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -365, to: currentDate)!
        
        // Create user profile patterns
        let userPatterns = generateUserWorkoutPatterns()
        
        // Track number of workouts generated
        var workoutsGenerated = 0
        
        // Generate life events that affect workout consistency
        let lifeEvents = generateLifeEvents(startDate: startDate, endDate: currentDate)
        
        // Generate workouts from start date to current date
        var currentProcessDate = startDate
        
        // Create phases of fitness journey
        let phases = generateTrainingPhases(startDate: startDate, endDate: currentDate)
        var currentPhaseIndex = 0
        var currentPhase = phases[currentPhaseIndex]
        
        while currentProcessDate <= currentDate {
            // Check if we need to move to the next phase
            if currentProcessDate >= currentPhase.endDate && currentPhaseIndex < phases.count - 1 {
                currentPhaseIndex += 1
                currentPhase = phases[currentPhaseIndex]
            }
            
            // Get day of week (1 = Sunday, 2 = Monday, etc.)
            let weekday = calendar.component(.weekday, from: currentProcessDate)
            
            // Check if this is a planned workout day based on the current phase
            if currentPhase.workoutDays.contains(weekday) {
                
                // Check if this date falls within a life event (vacation, illness, etc.)
                let isLifeEventDay = lifeEvents.contains { event in
                    currentProcessDate >= event.startDate && currentProcessDate <= event.endDate
                }
                
                // Determine if user will work out today based on consistency and life events
                let workoutProbability = isLifeEventDay ? 0.2 : currentPhase.consistency
                
                if Double.random(in: 0...1) <= workoutProbability {
                    // Select a template based on the current phase's focus
                    let template = selectTemplateForPhase(currentPhase, templates: templates, date: currentProcessDate)
                    
                    // Calculate progression factor based on current phase and days passed in phase
                    let daysSincePhaseStart = currentProcessDate.timeIntervalSince(currentPhase.startDate) / (24 * 60 * 60)
                    let progressFactor = calculateProgressForPhase(
                        phase: currentPhase,
                        daysSincePhaseStart: daysSincePhaseStart
                    )
                    
                    // Create a workout based on the template
                    let workout = createEnhancedWorkoutFromTemplate(
                        template: template,
                        date: currentProcessDate,
                        progressFactor: progressFactor,
                        phase: currentPhase,
                        userPatterns: userPatterns,
                        container: container
                    )
                    
                    container.mainContext.insert(workout)
                    workoutsGenerated += 1
                }
            }
            
            // Move to next day
            currentProcessDate = calendar.date(byAdding: .day, value: 1, to: currentProcessDate)!
        }
        
        print("Generated \(workoutsGenerated) demo workouts")
        
    } catch {
        print("Failed to pre-seed demo data: \(error)")
    }
}

// MARK: - Helper Models

struct UserWorkoutPatterns {
    // How the user approaches different types of workouts
    var preferredTimeRanges: [(start: Int, end: Int)] // Hours of day (0-23)
    var workoutDuration: (min: TimeInterval, max: TimeInterval) // Minutes
    var preferredExerciseGroups: [MuscleGroup: Double] // Preference weight for muscle groups
    var exerciseSubstitutionRate: Double // How often user switches exercises (0-1)
    var warmupSets: Int // Typical number of warmup sets
    var dropSetFrequency: Double // How often user does drop sets (0-1)
    var restDays: [Int] // Days when user typically doesn't work out (1-7)
    var notes: [String] // Sample workout notes the user might add
    var trackingConsistency: Double // How often user tracks full details vs just doing workout (0-1)
}

struct TrainingPhase {
    var name: String
    var startDate: Date
    var endDate: Date
    var focus: [MuscleGroup: Double] // Weighted focus on muscle groups
    var workoutDays: [Int] // Days of week when workouts happen (1-7)
    var consistency: Double // Workout adherence (0-1)
    var intensity: Double // How hard the user pushes (0-1)
    var volume: Double // Workout volume multiplier
    var progressionRate: Double // How fast weights increase
    var deload: Bool // Is this a deload phase?
    var templates: [String] // Preferred template names during this phase
}

struct LifeEvent {
    var reason: String
    var startDate: Date
    var endDate: Date
    var workoutImpact: Double // 0 = no workouts, 1 = normal workouts
}

// MARK: - Helper Functions

private func generateUserWorkoutPatterns() -> UserWorkoutPatterns {
    return UserWorkoutPatterns(
        preferredTimeRanges: [
            (6, 8),   // Early morning
            (17, 21)  // Evening
        ],
        workoutDuration: (min: 45 * 60, max: 90 * 60),
        preferredExerciseGroups: [
            .chest: 0.8,
            .back: 0.7,
            .arms: 0.9,
            .legs: 0.6,
            .shoulders: 0.7,
            .core: 0.5
        ],
        exerciseSubstitutionRate: 0.15,
        warmupSets: Int.random(in: 1...3),
        dropSetFrequency: 0.1,
        restDays: [1, 3, 5], // Sunday, Tuesday, Thursday
        notes: [
            "Feeling strong today! 💪",
            "Low energy but pushed through",
            "Increased weight on all exercises",
            "Had to cut short, only did main lifts",
            "Focused on form today",
            "Great pump!",
            "Added extra core work",
            "Shoulder feeling a bit tight",
            "New PR on bench!",
            "Trying new grip on rows",
            "",  // Sometimes no notes
            ""
        ],
        trackingConsistency: 0.85
    )
}

private func generateTrainingPhases(startDate: Date, endDate: Date) -> [TrainingPhase] {
    let calendar = Calendar.current
    let totalDays = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 365
    
    // Create several training phases throughout the year
    var phases: [TrainingPhase] = []
    var currentDate = startDate
    
    // Phase 1: Initial Adaptation (6-8 weeks)
    let initialPhaseDuration = Int.random(in: 42...56)
    let phase1End = calendar.date(byAdding: .day, value: initialPhaseDuration, to: currentDate)!
    
    phases.append(TrainingPhase(
        name: "Initial Adaptation",
        startDate: currentDate,
        endDate: phase1End,
        focus: [.chest: 0.5, .back: 0.5, .legs: 0.5, .arms: 0.5, .shoulders: 0.5, .core: 0.5],
        workoutDays: [2, 4, 6], // Mon, Wed, Fri
        consistency: 0.85,
        intensity: 0.6,
        volume: 0.8,
        progressionRate: 0.03, // Fast initial progress
        deload: false,
        templates: ["Beginner Full Body", "Full Body Basic", "Push Workout", "Pull Workout"]
    ))
    
    currentDate = phase1End
    
    // Phase 2: Strength Focus (10-12 weeks)
    let strengthPhaseDuration = Int.random(in: 70...84)
    let phase2End = calendar.date(byAdding: .day, value: strengthPhaseDuration, to: currentDate)!
    
    phases.append(TrainingPhase(
        name: "Strength Focus",
        startDate: currentDate,
        endDate: phase2End,
        focus: [.chest: 0.7, .back: 0.8, .legs: 0.9, .arms: 0.6, .shoulders: 0.6, .core: 0.4],
        workoutDays: [2, 4, 6, 7], // Mon, Wed, Fri, Sat
        consistency: 0.9,
        intensity: 0.8,
        volume: 0.9,
        progressionRate: 0.015,
        deload: false,
        templates: ["Strength Upper Body", "Power Lower Body", "Lower Body Strength", "Minimalist Strength"]
    ))
    
    currentDate = phase2End
    
    // Deload week
    let deloadEnd = calendar.date(byAdding: .day, value: 7, to: currentDate)!
    
    phases.append(TrainingPhase(
        name: "Deload",
        startDate: currentDate,
        endDate: deloadEnd,
        focus: [.chest: 0.5, .back: 0.5, .legs: 0.5, .arms: 0.5, .shoulders: 0.5, .core: 0.5],
        workoutDays: [2, 5], // Mon, Thu
        consistency: 0.95,
        intensity: 0.5,
        volume: 0.6,
        progressionRate: 0.0,
        deload: true,
        templates: ["Beginner Full Body", "Full Body Basic"]
    ))
    
    currentDate = deloadEnd
    
    // Phase 3: Hypertrophy (8-10 weeks)
    let hyperPhaseDuration = Int.random(in: 56...70)
    let phase3End = calendar.date(byAdding: .day, value: hyperPhaseDuration, to: currentDate)!
    
    phases.append(TrainingPhase(
        name: "Hypertrophy Focus",
        startDate: currentDate,
        endDate: phase3End,
        focus: [.chest: 0.8, .back: 0.8, .legs: 0.7, .arms: 0.9, .shoulders: 0.8, .core: 0.6],
        workoutDays: [2, 3, 5, 7], // Mon, Tue, Thu, Sat
        consistency: 0.85,
        intensity: 0.75,
        volume: 1.1,
        progressionRate: 0.01,
        deload: false,
        templates: ["Push Workout", "Pull Workout", "Chest Focus", "Back Development", "Shoulder Builder", "Arm Day"]
    ))
    
    currentDate = phase3End
    
    // Another deload week
    let deload2End = calendar.date(byAdding: .day, value: 7, to: currentDate)!
    
    phases.append(TrainingPhase(
        name: "Deload",
        startDate: currentDate,
        endDate: deload2End,
        focus: [.chest: 0.5, .back: 0.5, .legs: 0.5, .arms: 0.5, .shoulders: 0.5, .core: 0.5],
        workoutDays: [2, 5], // Mon, Thu
        consistency: 0.9,
        intensity: 0.5,
        volume: 0.6,
        progressionRate: 0.0,
        deload: true,
        templates: ["Beginner Full Body", "Full Body Basic"]
    ))
    
    currentDate = deload2End
    
    // Phase 4: Strength-Hypertrophy (Remaining time)
    phases.append(TrainingPhase(
        name: "Strength-Hypertrophy",
        startDate: currentDate,
        endDate: endDate,
        focus: [.chest: 0.8, .back: 0.8, .legs: 0.8, .arms: 0.8, .shoulders: 0.7, .core: 0.7],
        workoutDays: [2, 4, 5, 7], // Mon, Wed, Thu, Sat
        consistency: 0.88,
        intensity: 0.85,
        volume: 1.0,
        progressionRate: 0.005, // Slower progress, approaching plateau
        deload: false,
        templates: ["Upper Body Power", "Lower Body Strength", "Chest and Back", "Shoulders and Arms", "Leg Day"]
    ))
    
    return phases
}

private func generateLifeEvents(startDate: Date, endDate: Date) -> [LifeEvent] {
    let calendar = Calendar.current
    let totalDays = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 365
    
    var events: [LifeEvent] = []
    
    // Add a vacation
    var vacationStart = calendar.date(
        byAdding: .day,
        value: Int.random(in: 60...120),
        to: startDate
    )!
    
    let vacationDuration = Int.random(in: 5...10)
    let vacationEnd = calendar.date(byAdding: .day, value: vacationDuration, to: vacationStart)!
    
    events.append(LifeEvent(
        reason: "Vacation",
        startDate: vacationStart,
        endDate: vacationEnd,
        workoutImpact: 0.3
    ))
    
    // Add another vacation
    vacationStart = calendar.date(
        byAdding: .day,
        value: Int.random(in: 220...300),
        to: startDate
    )!
    
    let vacation2Duration = Int.random(in: 7...14)
    let vacation2End = calendar.date(byAdding: .day, value: vacation2Duration, to: vacationStart)!
    
    events.append(LifeEvent(
        reason: "Vacation",
        startDate: vacationStart,
        endDate: vacation2End,
        workoutImpact: 0.2
    ))
    
    // Add an illness
    let illnessStart = calendar.date(
        byAdding: .day,
        value: Int.random(in: 150...200),
        to: startDate
    )!
    
    let illnessDuration = Int.random(in: 3...7)
    let illnessEnd = calendar.date(byAdding: .day, value: illnessDuration, to: illnessStart)!
    
    events.append(LifeEvent(
        reason: "Illness",
        startDate: illnessStart,
        endDate: illnessEnd,
        workoutImpact: 0.1
    ))
    
    // Add a busy work period
    let busyStart = calendar.date(
        byAdding: .day,
        value: Int.random(in: 250...330),
        to: startDate
    )!
    
    let busyDuration = Int.random(in: 10...21)
    let busyEnd = calendar.date(byAdding: .day, value: busyDuration, to: busyStart)!
    
    events.append(LifeEvent(
        reason: "Busy at Work",
        startDate: busyStart,
        endDate: busyEnd,
        workoutImpact: 0.5
    ))
    
    return events
}

private func calculateProgressForPhase(phase: TrainingPhase, daysSincePhaseStart: Double) -> Double {
    // Base progression calculation
    let phaseDuration = phase.endDate.timeIntervalSince(phase.startDate) / (24 * 60 * 60)
    let normalizedProgress = min(1.0, daysSincePhaseStart / phaseDuration)
    
    // If it's a deload phase, we reduce weights
    if phase.deload {
        return 0.7 + (0.1 * normalizedProgress) // 70-80% of normal weights
    }
    
    // For regular phases, calculate a progressive increase
    // Progression curve based on phase's progression rate
    let progressionMultiplier = phase.progressionRate * daysSincePhaseStart
    
    // Start from previous phases' progress (around 0.7-0.8 typically)
    let baseProgress = 0.75
    
    // Add progression with diminishing returns
    return baseProgress + (progressionMultiplier / (1 + 0.1 * progressionMultiplier))
}

private func selectTemplateForPhase(_ phase: TrainingPhase, templates: [WorkoutTemplate], date: Date) -> WorkoutTemplate {
    // Find templates that match the phase's focus
    let preferredTemplates = templates.filter { template in
        phase.templates.contains(template.name)
    }
    
    if !preferredTemplates.isEmpty {
        // Get week number to create a consistent rotation
        let calendar = Calendar.current
        let weekOfYear = calendar.component(.weekOfYear, from: date)
        let dayOfWeek = calendar.component(.weekday, from: date)
        
        // Create a deterministic but varied selection that repeats weekly
        let index = (weekOfYear + dayOfWeek) % preferredTemplates.count
        return preferredTemplates[index]
    }
    
    // Fallback to random template if none match
    return templates.randomElement()!
}

@MainActor private func createEnhancedWorkoutFromTemplate(
    template: WorkoutTemplate,
    date: Date,
    progressFactor: Double,
    phase: TrainingPhase,
    userPatterns: UserWorkoutPatterns,
    container: ModelContainer
) -> Workout {
    // Calculate workout start time based on user patterns
    let calendar = Calendar.current
    let timeSlot = userPatterns.preferredTimeRanges.randomElement()!
    
    var startTimeComponents = calendar.dateComponents([.year, .month, .day], from: date)
    startTimeComponents.hour = Int.random(in: timeSlot.start...timeSlot.end)
    startTimeComponents.minute = [0, 15, 30, 45].randomElement()!
    
    let startTime = calendar.date(from: startTimeComponents)!
    
    // Calculate duration based on user patterns and phase
    let baseDuration = TimeInterval.random(in: userPatterns.workoutDuration.min...userPatterns.workoutDuration.max)
    let phaseDurationFactor = phase.deload ? 0.8 : (phase.volume * 0.3 + 0.7) // Deload workouts are shorter
    let duration = baseDuration * phaseDurationFactor
    
    let endTime = startTime.addingTimeInterval(duration)
    
    // Sometimes add workout notes
    let addNote = Double.random(in: 0...1) < 0.4
    let workoutNote = addNote ? userPatterns.notes.randomElement()! : ""
    
    // Create the workout
    let workout = Workout(
        date: startTime,
        name: template.name,
        duration: duration,
        notes: workoutNote,
        exercises: [],
        endDate: endTime
    )
    
    // Get all exercises for potential substitutions
    let exerciseDescriptor = FetchDescriptor<Exercise>()
    var allExercises: [Exercise] = []
    do {
        allExercises = try container.mainContext.fetch(exerciseDescriptor)
    } catch {
        print("Failed to fetch exercises: \(error)")
    }
    
    // Copy exercises from template with potential substitutions
    for templateExercise in template.exercises.sorted(by: { $0.order < $1.order }) {
        // Decide if we should substitute this exercise
        let shouldSubstitute = Double.random(in: 0...1) < userPatterns.exerciseSubstitutionRate
        
        var exercise = templateExercise.exercise
        
        if shouldSubstitute && !allExercises.isEmpty {
            // Find a substitute exercise that works the same muscles
            let possibleSubstitutes = allExercises.filter { potentialExercise in
                // Check if it works at least one of the same primary muscles
                let primaryMuscleMatch = !Set(potentialExercise.primaryMuscles).isDisjoint(with: Set(exercise.primaryMuscles))
                
                // Ensure it's not the same exercise
                return primaryMuscleMatch && potentialExercise.name != exercise.name
            }
            
            if let substitute = possibleSubstitutes.randomElement() {
                exercise = substitute
            }
        }
        
        let workoutExercise = WorkoutExercise(
            exercise: exercise,
            order: templateExercise.order,
            sets: []
        )
        workoutExercise.workout = workout
        
        // Determine target weight based on the exercise
        let targetWeight = determineTargetWeight(for: exercise)
        
        // Add warmup sets
        if exercise.trackWeight && !phase.deload && Double.random(in: 0...1) < 0.8 {
            for i in 0..<userPatterns.warmupSets {
                let warmupFactor = Double(i + 1) / Double(userPatterns.warmupSets + 1)
                let warmupWeight = (targetWeight ?? 20.0) * progressFactor * warmupFactor
                let roundedWeight = round(warmupWeight / 2.5) * 2.5
                
                let warmupSet = WorkoutSet(
                    order: i,
                    reps: Int.random(in: 8...12),
                    weight: roundedWeight > 0 ? roundedWeight : 2.5,
                    time: nil,
                    distance: nil
                )
                warmupSet.type = .warmup
                warmupSet.completed = true
                workoutExercise.sets.append(warmupSet)
            }
        }
        
        // Working sets based on template
        let baseSets = templateExercise.sets.sorted(by: { $0.order < $1.order })
        let workingSetsCount = phase.deload ? max(2, baseSets.count - 1) : baseSets.count
        
        for i in 0..<workingSetsCount {
            // Get the template set or create a new one if we've added sets
            let templateSet = i < baseSets.count ? baseSets[i] : baseSets.last!
            
            // Calculate the working weight with phase-specific progression
            var weight: Double? = nil
            if templateSet.weight != nil || (exercise.trackWeight && templateSet.reps != nil) {
                // Base weight calculation
                weight = (targetWeight ?? 20.0) * progressFactor
                
                // Add day-to-day variation and phase intensity
                let variation = Double.random(in: 0.97...1.03)
                let intensityFactor = phase.intensity * 0.2 + 0.9 // 0.9-1.1 based on intensity
                weight! *= variation * intensityFactor
                
                // Round to nearest 2.5 for realism
                weight = round(weight! / 2.5) * 2.5
                
                // Make sure weight is at least the bar weight
                weight = max(weight!, 20.0) // Assuming standard barbell weight
                
                // For later sets, slightly decrease weight due to fatigue
                if i > 2 && Double.random(in: 0...1) < 0.3 {
                    weight = weight! - 2.5
                }
            }
            
            // Calculate reps based on phase and template
            var reps = templateSet.reps
            if let baseReps = reps {
                // Phase volume affects number of reps
                let volumeFactor = phase.deload ? -2 : (phase.volume > 1.0 ? 2 : 0)
                
                // As weight increases, reps might decrease slightly
                let intensityAdjustment = phase.intensity > 0.8 ? -1 : 1
                
                // Random variation
                let repsVariation = Int.random(in: -1...1)
                
                reps = max(1, baseReps + volumeFactor + intensityAdjustment + repsVariation)
            }
            
            // Create the working set
            let workingSet = WorkoutSet(
                order: workoutExercise.sets.count,
                reps: reps,
                weight: weight,
                time: templateSet.time,
                distance: templateSet.distance
            )
            workingSet.completed = true
            workingSet.type = .working
            
            // Add RPE to some sets, more likely on heavier compound exercises
            let isCompound = exercise.primaryMuscles.count > 1 ||
                             exercise.name.lowercased().contains("squat") ||
                             exercise.name.lowercased().contains("deadlift") ||
                             exercise.name.lowercased().contains("bench") ||
                             exercise.name.lowercased().contains("row")
            
            let rpeChance = isCompound ? 0.7 : 0.3
            if Double.random(in: 0...1) < rpeChance {
                // RPE based on phase intensity and set number
                let baseRPE = phase.intensity * 2 + 7 // 7-9 range
                let setAdjustment = Double(i) * 0.2 // Later sets feel harder
                let rpeValue = min(10.0, baseRPE + setAdjustment)
                
                // Round to nearest RPE step
                workingSet.RPE = [6.5, 7.0, 7.5, 8.0, 8.5, 9.0, 9.5, 10.0].min {
                    abs($0 - rpeValue) < abs($1 - rpeValue)
                }
            }
            
            workoutExercise.sets.append(workingSet)
        }
        
        // Occasionally add drop sets on isolation exercises
        let isIsolation = exercise.primaryMuscles.count == 1
        let isHypertrophyFocused = phase.volume > 0.9
        
        if isIsolation && isHypertrophyFocused && Double.random(in: 0...1) < userPatterns.dropSetFrequency {
            // Get the last working set as reference
            if let lastSet = workoutExercise.sets.last(where: { $0.type == .working }),
               let lastWeight = lastSet.weight, lastWeight > 5.0 {
                
                // Create a drop set with ~70-80% of the weight
                let dropWeight = round((lastWeight * Double.random(in: 0.7...0.8)) / 2.5) * 2.5
                
                let dropSet = WorkoutSet(
                    order: workoutExercise.sets.count,
                    reps: Int.random(in: 10...15),
                    weight: dropWeight,
                    time: nil,
                    distance: nil
                )
                dropSet.completed = true
                dropSet.type = .working
                
                workoutExercise.sets.append(dropSet)
            }
        }
        
        workout.exercises.append(workoutExercise)
    }
    
    return workout
}

// Helper function to determine an appropriate target weight for an exercise
private func determineTargetWeight(for exercise: Exercise) -> Double? {
    // If the exercise doesn't track weight, return nil
    if !exercise.trackWeight {
        return nil
    }
    
    // Determine appropriate weight ranges based on exercise name
    // These are somewhat realistic final weights for an intermediate lifter
    let exerciseName = exercise.name.lowercased()
    
    // Compound exercises
    if exerciseName.contains("squat") {
        return Double.random(in: 100...140)
    } else if exerciseName.contains("deadlift") {
        return Double.random(in: 120...160)
    } else if exerciseName.contains("bench press") {
        if exerciseName.contains("incline") {
            return Double.random(in: 70...100)
        } else {
            return Double.random(in: 80...120)
        }
    } else if exerciseName.contains("overhead press") || exerciseName.contains("military press") {
        return Double.random(in: 50...70)
    } else if exerciseName.contains("row") {
        return Double.random(in: 70...100)
    } else if exerciseName.contains("leg press") {
        return Double.random(in: 150...250)
    }
    
    // Isolation exercises
    else if exerciseName.contains("curl") {
        if exerciseName.contains("barbell") {
            return Double.random(in: 30...50)
        } else {
            return Double.random(in: 10...20) // Dumbbell curl (per arm)
        }
    } else if exerciseName.contains("extension") {
        if exerciseName.contains("leg") {
            return Double.random(in: 50...80)
        } else {
            return Double.random(in: 20...40) // Triceps
        }
    } else if exerciseName.contains("raise") {
        return Double.random(in: 8...15) // Lateral raises, etc.
    } else if exerciseName.contains("flye") {
        return Double.random(in: 10...20)
    }
    
    // Default weights for unspecified exercises
    else if exercise.primaryMuscles.contains(.biceps) || exercise.primaryMuscles.contains(.triceps) {
        return Double.random(in: 15...35)
    } else if exercise.primaryMuscles.contains(.chest) {
        return Double.random(in: 40...70)
    } else if exercise.primaryMuscles.contains(.quads) || exercise.primaryMuscles.contains(.hamstrings) {
        return Double.random(in: 50...100)
    } else if exercise.primaryMuscles.contains(.shoulders) {
        return Double.random(in: 20...40)
    } else if exercise.primaryMuscles.contains(.lats) || exercise.primaryMuscles.contains(.traps) {
        return Double.random(in: 50...80)
    }
    
    // Fallback for other exercises
    return Double.random(in: 20...50)
}
