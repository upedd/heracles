//
//  WorkoutScreen.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 13/02/2025.
//

import SwiftUI

struct WorkoutScreen: View {
    @Environment(\.modelContext) private var modelContext
    //@Binding var isPopupOpen: Bool
    //@ObservedObject var timerManager: TimerManager
    var startEmptyWorkout: () -> Void
    var body: some View {
        NavigationStack {
            ScrollView {
                Button {
                    startEmptyWorkout()
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
    
    
}

#Preview {
    WorkoutScreen(startEmptyWorkout: {})
}
