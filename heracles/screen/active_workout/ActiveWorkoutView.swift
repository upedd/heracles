//
//  ActiveWorkoutView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 13/02/2025.
//

import SwiftUI
import SwiftData

// TODO: add recents
struct SelectExercisesView: View {
    @Query private var exercises: [Exercise]
    @State private var selection = Set<Exercise>()
    @State private var searchText = ""
    @Environment(\.dismiss) var dismiss
    
    var onDone: (Set<Exercise>) -> Void
    
    var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return exercises
        }
        return exercises.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredExercises, id: \.self, selection: $selection) { exercise in
                
                Text(exercise.name)
            }
            .environment(\.editMode, .constant(EditMode.active))
            .navigationTitle(selection.isEmpty ? "Select Exercises" : "\(selection.count) Selected")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        onDone(selection)
                        dismiss()
                    }.bold()
                }
            }
            .searchable(text: $searchText)
        }
    }
}

struct ControlButtonLabelStyle : LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .center) {
            configuration.icon
                .fontWeight(.heavy)
                .imageScale(.large)
            configuration.title
                .font(.caption)
        }
    }
}

struct ControlButtonStyle : ButtonStyle {
    var color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            configuration.label
                .padding()
                .frame(maxWidth: .infinity)
                .background(Material.regular)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .foregroundStyle(.primary)
                .labelStyle(ControlButtonLabelStyle())
            color.blendMode(.multiply)
        }
    }
}



extension TimeInterval {
    var formatted: String {
            let hours = Int(self) / 3600
            let minutes = (Int(self) % 3600) / 60
            let seconds = Int(self) % 60
            
            if hours > 0 {
                return String(format: "%d:%02d:%02d", hours, minutes, seconds)
            } else {
                return String(format: "%02d:%02d", minutes, seconds)
            }
    }
}

struct ActiveWorkoutView: View {
    @Bindable var workout: Workout
    @ObservedObject var timerManager: TimerManager
    
    @State var selection = Set<Exercise>()
    @State var editMode = EditMode.active
    
    @State private var isAddingExercises = false
    @State private var showCancellationWarning = false
    @State private var showFinishWarning = false
    
    @Environment(\.modelContext) private var modelContext
    
    
    var hasAnyExercises: Bool {
        !workout.exercises.isEmpty
    }
    
    var madeAnyChanges: Bool {
        return workout.name != "" || workout.notes != "" || hasAnyExercises
    }
    var body: some View {
        NavigationStack {
            Form {
                // TODO: unpause on changes
                // TODO: light mode!
                // TODO: cleanup
                // TODO: after workout summary!
                VStack(alignment: .center) {
                    Text(timerManager.elapsedTime.formatted)
                        .font(.system(.largeTitle, design: .rounded, weight: .semibold))
                    HStack {
                        Button {
                            if madeAnyChanges {
                                showCancellationWarning = true
                            } else {
                                modelContext.delete(workout)
                            }
                        } label: {
                            Label("Cancel", systemImage: "xmark")
                        }
                        .buttonStyle(ControlButtonStyle(color: .red))
                        Button {
                            timerManager.isRunning ? timerManager.pause() : timerManager.start()
                        } label: {
                            Label(timerManager.isRunning ? "Pause" : "Resume", systemImage: timerManager.isRunning ? "pause" : "play.fill")
                        }
                        .buttonStyle(ControlButtonStyle(color: .yellow))
                        Button {
                            if hasAnyExercises {
                                showFinishWarning = true
                            } else {
                                showCancellationWarning = true
                            }
                        } label: {
                            Label("Finish", systemImage: "checkmark")
                        }
                        .buttonStyle(ControlButtonStyle(color: .green))
                    }
                        
                }
                .listRowInsets(EdgeInsets())
                .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                Section {
                    TextField("Name", text: $workout.name)
                    TextField("Notes", text: $workout.notes)
                }
                Section {
                    ForEach(workout.exercises) { exercise in
                        NavigationLink {
                            ActiveWorkoutExerciseView(exercise: exercise)
                        } label: {
                            HStack {
                                Text(exercise.exercise.name)
                                Spacer()
                                Text("\(exercise.sets.filter {$0.completed}.count)/\(exercise.sets.count)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        workout.exercises.remove(atOffsets: indexSet)
                    }
                    .onMove { indices, newOffset in
                        workout.exercises.move(fromOffsets: indices, toOffset: newOffset)
                    }

                    Button {
                        isAddingExercises.toggle()
                    } label: {
                        Label("Add Exercises", systemImage: "plus")
                    }
                }
                
            }
            .toolbar {
                EditButton()
            }
            .sheet(isPresented: $isAddingExercises) {
                SelectExercisesView(onDone: { selected in
                    for exercise in selected {
                        workout.exercises.append(WorkoutExercise(exercise: exercise))
                    }
                })
            }
            .confirmationDialog("Discard Workout?", isPresented: $showCancellationWarning) {
                Button("Discard Workout", role: .destructive) {
                    modelContext.delete(workout)
                }
            } message: {
                Text("All progress will be lost.")
            }
            .confirmationDialog("Finish Workout?", isPresented: $showFinishWarning) {
                Button("Finish Workout") {
                    workout.active = false
                }
            } message: {
                // TODO: add message?
                //Text("All uncompleted sets will be discarded.")
            }
            .onChange(of: workout.exercises) {
                timerManager.start()
            }
        }
    }
}

#Preview {
    let workout = Workout();
    ActiveWorkoutView(workout: workout, timerManager: TimerManager())
        .modelContainer(for: Exercise.self, inMemory: true) { result in
            do {
                let container = try result.get()
                preloadExercises(container)
            } catch {
                print("Failed to create model container.")
            }
        }
}
