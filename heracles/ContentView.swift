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
    
    var activeWorkout: Workout? {
        return workouts.filter { $0.active == true }.first
    }
    var body: some View {
        TabView {
            SummaryScreen()
                .tabItem {
                    Label("Summary", systemImage: "square.grid.2x2.fill")
                }
            
            
            WorkoutScreen(isPopupOpen: $isPopupOpen, timerManager: timerManager)
                .tabItem {
                    Label("Workout", systemImage: "dumbbell")
                }
            
            HistoryScreen()
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
                //                    .popupBarItems {
                //                        ToolbarItemGroup(placement: .popupBar) {
                //                            Button {
                //                                timerManager.pause()
                //                            } label: {
                //                                Image(systemName: "play.fill")
                //                            }
                //                        }
                //                    }
                
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Workout.self, inMemory: true) { result in
            do {
                let container = try result.get()
                preloadExercises(container)
            } catch {
                print("Failed to create model container.")
            }
        }
}
