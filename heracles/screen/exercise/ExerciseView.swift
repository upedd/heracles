//
//  ExerciseView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 14/02/2025.
//

import SwiftUI
import YouTubePlayerKit
import SwiftData

struct ExerciseView: View {
    enum Tab: String, CaseIterable, Identifiable {
        case info
        case charts
        case history
        
        var id: Self {self}
    }
    
    @State private var selectedTab: Tab = .info
    
    @Bindable var exercise: Exercise
    @Query var workoutExercises: [WorkoutExercise]
    
    var body: some View {
        VStack {
            if selectedTab == .info {
                ExerciseInfoView(exercise: exercise)
            } else  if selectedTab == .history {
                ExerciseHistoryView(workoutExercises: workoutExercises.filter {$0.exercise == exercise}) // TODO: performance improvements
            } else {
                ExerciseChartsView()
            }
        }
            .navigationTitle(exercise.name)
            .navigationBarTitleDisplayMode(.inline)
            .customHeaderView({
                Picker("Section", selection: $selectedTab) {
                    ForEach(Tab.allCases) { tab in
                        Text(tab.rawValue.capitalized)
                    }
                }.pickerStyle(.segmented)
                    .padding()
            }, height: 50)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Workout.self, configurations: config)
    
    let exercise = Exercise(name: "Bench Press", type: .weight_reps, primaryMuscleGroup: .chest, secondaryMuscleGroups: [.triceps, .front_delts])
    
    exercise.instructions = "Lie flat on a bench with feet firmly on the ground.\nGrip the barbell slightly wider than shoulder-width apart.\nUnrack the barbell and hold it straight above your chest with arms fully extended.\nLower the barbell slowly to your mid-chest, keeping elbows at a 45-degree angle.\nPause briefly when the barbell touches your chest.\nPush the barbell back up to the starting position, exhaling as you press.\nLock out your arms at the top and repeat for desired reps.\nRack the barbell safely after completing your set."
    
    exercise.pinnedNotes = [
        ExerciseNote(text: "Keep your back flat on the bench"),
        ExerciseNote(text: "Don't flare your elbows out"),
        ExerciseNote(text: "Use a spotter for heavy weights")
    ]
    
    exercise.youtubeVideoURL = "https://www.youtube.com/watch?v=U5zrloYWwxw"
    
    
    let workout_exercises: [WorkoutExercise] = [
        .init(exercise: exercise, sets: [
            .init(reps: 8, weight: 60),
            .init(reps: 8, weight: 70),
            .init(reps: 6, weight: 70)
        ]),
        .init(exercise: exercise, sets: [
            .init(reps: 8, weight: 60),
            .init(reps: 8, weight: 70),
            .init(reps: 6, weight: 70)
        ]),
        .init(exercise: exercise, sets: [
            .init(reps: 8, weight: 60),
            .init(reps: 8, weight: 70),
            .init(reps: 6, weight: 70)
        ]),
    ]
    
    
    
    let workout = Workout(name: "Chest Day", exercises: workout_exercises)
    
    let workout2 = Workout(name: "Morning Workout", exercises: workout_exercises)
    workout2.date =  Date.now.addingTimeInterval(-86400 * 64)
    
    workout_exercises[0].workout = workout
    workout_exercises[1].workout = workout
    workout_exercises[2].workout = workout2
    
    workout.exercises = [workout_exercises[0], workout_exercises[1]]
    workout2.exercises = [workout_exercises[2]]
    
    container.mainContext.insert(workout)
    container.mainContext.insert(workout2)
    
    return NavigationStack {
        ExerciseView(exercise: exercise)
    }
    .modelContainer(container)
}

