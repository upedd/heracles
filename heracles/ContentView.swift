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
    @StateObject private var timerManager = TimerManager()
    
    var activeWorkout: Workout? {
        let first = workouts.first
        if let first {
            if first.active {
                return first
            }
        }
        return nil
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
                ActiveWorkoutView(workout: activeWorkout, timerManager: timerManager).popupTitle("Active Workout", subtitle: timerManager.elapsedTime.formatted)
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
