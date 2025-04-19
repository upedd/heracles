//
//  ExerciseHistoryView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 14/02/2025.
//

import SwiftUI
import SwiftData
// TODO: visuals consistency
struct WorkoutExerciseLink : View {
    var workoutExercise: WorkoutExercise
    var exercises: [Exercise]
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(workoutExercise.workout!.name)
                        .font(.body)
                    Spacer()
                    Text(workoutExercise.workout!.date.formatted(.dateTime))
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(Color(.secondaryLabel))
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.tertiary)
                        .fontWeight(.semibold)
                        .imageScale(.small)
                    
                    
                }
                .padding(.bottom, 5)
                ForEach(workoutExercise.sets) { set in
                    HStack {
                        Text(set.formatted)
                            .font(.subheadline)
                        
                    }
                }
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            NavigationLink {
                WorkoutView(workout: workoutExercise.workout!, exercises: exercises)
            } label: {
                EmptyView()

            }
            .opacity(0)
            
        }.listRowSeparator(.hidden)
    }
}

struct ExerciseHistorySectionHeaderView : View {
    var title: String
    var body : some View {
        HStack {
            Text(title)
                .font(.title2.bold())
                .foregroundStyle(Color.primary)
                .padding(.leading, 20)
                .padding(.vertical, 10)
            Spacer()
        }
        .listRowInsets(EdgeInsets())
        .background(Color(.systemBackground))
    }
}

struct ExerciseHistoryView: View {
    var workoutExercises: [WorkoutExercise]
    // performance!
    var groupedExercises: [String: [WorkoutExercise]] {
        Dictionary(grouping: workoutExercises.filter { !$0.workout!.active }, by: {$0.workout!.date.formatted(.dateTime.month(.wide).year())})
    }
    @Query private var exercises: [Exercise]
    
    var body: some View {
        List(Array(groupedExercises.keys), id: \.self) { group in
            Section {
                ForEach(groupedExercises[group]!) { workoutExercise in
                    WorkoutExerciseLink(workoutExercise: workoutExercise, exercises: exercises)
                }
            } header: {
                ExerciseHistorySectionHeaderView(title: group)
            }
            
        }
        .overlay {
            if groupedExercises.isEmpty {
                ContentUnavailableView {
                    Label("No Logged Sets", systemImage: "archivebox")
                } description: {
                    Text("Exercise sets will appear here once you start logging them.")
                }
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
    let exercise = Exercise(name: "Bench Press", type: .weight_reps, primaryMuscleGroup: .chest, secondaryMuscleGroups: [.triceps, .shoulders])
    
    let workout_exercises: [WorkoutExercise] = [
        .init(exercise: exercise, order: 0, sets: [
            .init(order: 0, reps: 8, weight: 60),
            .init(order: 1, reps: 8, weight: 70),
            .init(order: 2, reps: 6, weight: 70)
        ]),
        .init(exercise: exercise, order: 1, sets: [
            .init(order: 0, reps: 8, weight: 60),
            .init(order: 1, reps: 8, weight: 70),
            .init(order: 2, reps: 6, weight: 70)
        ]),
        .init(exercise: exercise, order: 2, sets: [
            .init(order: 0, reps: 8, weight: 60),
            .init(order: 1, reps: 8, weight: 70),
            .init(order: 2, reps: 6, weight: 70)
        ]),
    ]
    
    let workout = Workout(name: "Chest Day", exercises: workout_exercises)
    
    let workout2 = Workout(name: "Morning Workout", exercises: workout_exercises)
    workout2.date =  Date.now.addingTimeInterval(-86400 * 64)
    
    workout_exercises[0].workout = workout
    workout_exercises[1].workout = workout
    workout_exercises[2].workout = workout2
    
    return ExerciseHistoryView(workoutExercises: workout_exercises)
}
