//
//  ContentView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 13/02/2025.
//

import SwiftUI
import SwiftData
import LNPopupUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var isPopupBarPresented = true
    @State private var isPopupOpen = false
    @Query private var workouts: [Workout]
    @StateObject private var timerManager = TimerManager.make(id: "workout")
    @State private var afterDiscardWorkoutFn: (() -> Void)?
    @State private var showDiscardWorkout = false
    
    func startEmptyWorkout() {
        startWorkout([], nil)
    }
    
    func startWorkout(_ exercises: [WorkoutExercise], _ name: String?) {
        if activeWorkout != nil {
            showDiscardWorkout = true
            afterDiscardWorkoutFn = { startWorkout(exercises, name) }
            return
        }
        let workout = Workout()
        workout.active = true
        modelContext.insert(workout)
        timerManager.reset()
        timerManager.start()
        // TODO: fixme
        workout.exercises = exercises.map {
            let workoutExercise = WorkoutExercise(exercise: $0.exercise, order: $0.order)
            for set in $0.sets {
                let workoutSet = WorkoutSet(order: set.order)
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
        .confirmationDialog("Discard Current Workout?", isPresented: $showDiscardWorkout, titleVisibility: .visible, presenting: afterDiscardWorkoutFn, actions: { fn in
            Button("Discard", role: .destructive) {
                if let workout = activeWorkout {
                    modelContext.delete(workout)
                    try! modelContext.save() // prob bad idea!
                }
                fn()
            }
        }, message: { _ in
            Text("You already have a workout in progress. Do you want to discard it and start a new one?")
        })
        .popup(isBarPresented: $isPopupBarPresented, isPopupOpen: $isPopupOpen) {
            if let activeWorkout {
                ActiveWorkoutView(workout: activeWorkout, timerManager: timerManager)
                    .popupTitle({
                        Text(activeWorkout.name)
                            .multilineTextAlignment(.leading)

                            .frame(maxWidth: .infinity, alignment: .leading)
                    }, subtitle: {
                        Group {
                            if timerManager.isRunning {
                                Text(TimeDataSource<Date>.currentDate, format: .stopwatch(startingAt: .now.addingTimeInterval(-timerManager.elapsedTime), maxPrecision: .seconds(1)))
                                    
                            } else {
                                Text(Date.now, format: .stopwatch(startingAt: .now.addingTimeInterval(-timerManager.elapsedTime), maxPrecision: .seconds(1)))
                            }
                        }
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    })
//                    .popupTitle(activeWorkout.name, subtitle: timerManager.elapsedTime.formatted)
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
