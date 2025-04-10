//
//  WorkoutScreen.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 13/02/2025.
//

import SwiftUI

struct WorkoutScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPopupOpen: Bool
    @ObservedObject var timerManager: TimerManager
    var body: some View {
        NavigationStack {
            ScrollView {
                Button {
                    startWorkout()
                } label: {
                    HStack {
                        Spacer()
                        Label {
                            Text("Start Workout")
                        } icon: {
                            Image(systemName: "plus.circle.fill")
                        }
                         .font(.headline)
                        .padding(.all, 8)
                        Spacer()
                    }
                }.buttonStyle(.borderedProminent)
                    .padding()
                    
            }.navigationTitle("Workout")
        }
    }
    
    func startWorkout() {
        let workout = Workout()
        workout.active = true
        modelContext.insert(workout)
        timerManager.reset()
        timerManager.start()
        workout.name = "Workout" // TODO(polish): better default names for workouts, we should be constructing those names based on the time of the day and muscle groups of exercises. Examples: Morning Push Workout, Evening Full Body Workout, Afternoon Arms Workout
        isPopupOpen = true
    }
}

#Preview {
    WorkoutScreen(isPopupOpen: .constant(false), timerManager: .make(id: "preview"))
}
