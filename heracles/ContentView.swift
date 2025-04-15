//
//  ContentView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 13/02/2025.
//

import SwiftUI
import SwiftData
import LNPopupUI

//extension EnvironmentValues {
//    @Entry var stopwatchTimerManager: TimerManager = TimerManager.make(id: "workout")
//}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var isPopupBarPresented = true
    @State private var isPopupOpen = false
    @Query private var workouts: [Workout]
    @StateObject private var timerManager = TimerManager.make(id: "workout")
    
    
    func startEmptyWorkout() {
        startWorkout([], nil)
    }
    
    func startWorkout(_ exercises: [WorkoutExercise], _ name: String?) {
        let workout = Workout()
        workout.active = true
        modelContext.insert(workout)
        timerManager.reset()
        timerManager.start()
        // TODO: fixme
        workout.exercises = exercises.map {
            let workoutExercise = WorkoutExercise(exercise: $0.exercise)
            for set in $0.sets {
                let workoutSet = WorkoutSet()
                workoutSet.reps = set.reps
                workoutSet.weight = set.weight
                workoutExercise.sets.append(workoutSet)
            }
            return workoutExercise
        }
        workout.name = name ?? "Workout" // TODO(polish): better default names for workouts, we should be constructing those names based on the time of the day and muscle groups of exercises. Examples: Morning Push Workout, Evening Full Body Workout, Afternoon Arms Workout
        isPopupOpen = true
    }
    
    var activeWorkout: Workout? {
        return workouts.filter { $0.active == true }.first
    }
    var body: some View {
        TabView {
            SummaryScreen()
                .tabItem {
                    Label("Summary", systemImage: "square.grid.2x2.fill")
                }
            
            
            WorkoutScreen(startWorkout: startWorkout)
                .tabItem {
                    Label("Workout", systemImage: "dumbbell")
                }
            
            HistoryScreen(startEmptyWorkout: startEmptyWorkout)
                .tabItem {
                    Label("History", systemImage: "clock")
                }
            
            ExercisesScreen()
                .tabItem {
                    Label("Exercises", systemImage: "books.vertical")
                }
        }
            
        .onChange(of: activeWorkout, {
            if activeWorkout != nil {
                isPopupBarPresented = true
            } else {
                isPopupBarPresented = false
                isPopupOpen = false
            }
        })
        .onAppear {
            if activeWorkout != nil {
                isPopupBarPresented = true
            } else {
                isPopupBarPresented = false
                isPopupOpen = false
            }
        }
        .popup(isBarPresented: $isPopupBarPresented, isPopupOpen: $isPopupOpen) {
            if let activeWorkout {
                ActiveWorkoutView(workout: activeWorkout, timerManager: timerManager)
                    .popupTitle(activeWorkout.name, subtitle: timerManager.elapsedTime.formatted)
                    .popupBarItems(trailing: {
                        Button {
                            if timerManager.isRunning {
                                timerManager.pause()
                            } else {
                                timerManager.start()
                            }
                            
                        } label: {
                            Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                        }
                        .foregroundStyle(.white)
                        
                    })
                
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Workout.self, WorkoutTemplate.self]
                              , inMemory: true) { result in
            do {
                let container = try result.get()
                preloadExercises(container)
                preloadWorkoutTemplates(container)
            } catch {
                print("Failed to create model container.")
            }
        }
}
