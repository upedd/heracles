//
//  ActiveWorkoutView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 04/10/2024.
//

import SwiftUI
import SwiftData
import Foundation


struct CheckToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Label {
                
            } icon: {
                Image(systemName: configuration.isOn ? "inset.filled.circle" : "circle")
                    .foregroundStyle(configuration.isOn ? Color.accentColor : .secondary)
                    .accessibility(label: Text(configuration.isOn ? "Checked" : "Unchecked"))
                    .imageScale(.large)
            }
        }
        .buttonStyle(.plain)
    }
}


struct ActiveWorkoutSet: View {
    @Bindable var set: Set
    @ScaledMetric private var textFieldWidth = 70
    
    var body: some View {
        HStack(alignment: .center) {
            Toggle("Completed", isOn: $set.completed)
                .toggleStyle(CheckToggleStyle())
                .labelsHidden()
                .sensoryFeedback(.selection, trigger: set.completed)
            TextField("Set label", text: $set.label)
                .labelsHidden()
            Spacer()
            TextField("", value: $set.reps, format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .frame(maxWidth: textFieldWidth)
                .disabled(set.completed)
                .accessibilityLabel("reps")
                TextField("", value: $set.weight, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                    .frame(maxWidth: textFieldWidth)
                    .disabled(set.completed)
                    .accessibilityLabel("weight")
        }
    }
}

// TODO: mess
struct ActiveWorkoutExerciseSetHeader: View {
    @ScaledMetric private var textFieldWidth = 70
    @State private var isOn = false
    var body: some View {
        HStack {
            Text("label")
            Spacer()
            Text("reps")
                .frame(maxWidth: textFieldWidth, alignment: .leading)
            Text("weight (kg)")
                .frame(maxWidth: textFieldWidth)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding([.leading], 44) // TODO: breaks type!
    }
}

struct ActiveWorkoutNewSet: View {
    @Bindable var exercise: WorkoutExercise
    var body: some View {
        Button("New Set", systemImage: "plus.circle", action: newSet)
            .foregroundStyle(Color.accentColor)
            .padding( .vertical, 4)
        
    }
    
    func newSet() {
        exercise.sets.append(Set(label: "Set #\(exercise.sets.count)"))
    }
}

struct AddExerciseDialog: View {
    @Bindable var workout: Workout
    
    @Query
    private var exercises: [Exercise]
    
    @State private var searchText = ""

    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(filteredExercises) { exercise in
                HStack {
                    Text(exercise.name)
                    Spacer()
                    Button("add \(exercise.name)", systemImage: "plus") {
                        addExercise(exercise: exercise)
                    }
                    .labelStyle(.iconOnly)
                }
                
            }
            .navigationTitle("Add Exercise")
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }.searchable(text: $searchText)
    }
    
    var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return exercises
        } else {
            return exercises.filter {$0.name.localizedCaseInsensitiveContains(searchText)}
        }
    }
    
    func addExercise(exercise: Exercise) {
        let workoutExercise = WorkoutExercise()
        workoutExercise.exercise = exercise
        workoutExercise.sets.append(Set(label: "Set #1"))
        workout.exercies.append(workoutExercise)
        dismiss()
    }
}

struct MyDisclosureStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Image(systemName: "chevron.right")
                .rotationEffect(.degrees(configuration.isExpanded ? 90 : 0))
                .foregroundStyle(Color.accentColor)
                .font(.system(size: 13, weight: .bold))
                
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                configuration.isExpanded.toggle()
            }
        }.padding(.horizontal, 20)
        if configuration.isExpanded {
            configuration.content.padding(.horizontal, 20)
        }
    }
}


struct ActiveWorkoutView : View {
    @Bindable var workout: Workout
    @State private var isExpanded = Swift.Set<WorkoutExercise>()
    @State private var showAddExercise: Bool = false
    
    var body: some View {
        VStack {
            List {
                ForEach(workout.exercies) { exercise in
                        DisclosureGroup {
                            // TODO: custom discloure group styling
                            ActiveWorkoutExerciseSetHeader()
                            ForEach(exercise.sets) { set in
                                ActiveWorkoutSet(set: set)
                                    .listRowSeparator(.visible)
                            }
                            ActiveWorkoutNewSet(exercise: exercise)
                        } label: {
                            Text(exercise.exercise?.name ?? "Unknown exercise")
                                .font(.title2.bold())
                        }
                        .disclosureGroupStyle(MyDisclosureStyle())
                        .padding(.bottom, 10)
            
    
                }
                .listRowSeparator(.hidden)
                Button {
                    showAddExercise.toggle()
                } label: {
                    HStack {
                        Spacer()
                        Text("Add Exercise")
                            .foregroundStyle(Color.accentColor)
                            .font(.headline)
                            .padding(.all, 8.0)
                        
                        Spacer()
                    }
                }
                .buttonStyle(.bordered)
                .padding()
                .listRowSeparator(.hidden)
                
            }
            .listRowSeparator(.visible, edges: [.top, .bottom])
            .listStyle(.inset)
            .padding(.horizontal, -20)
                        
        }
        .navigationTitle(workout.name)
            

            .sheet(isPresented: $showAddExercise) {
                AddExerciseDialog(workout: workout)
            }
            .toolbar {
                    Button("Menu", systemImage: "ellipsis.circle") {
                        
                    }
                    Button("Finish") {}
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                
            }
        
            
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Workout.self, configurations: config)

    let workout = Workout(name: "Morning Workout", date: Date.now)
    let dumbellRow = Exercise(name: "Dumbell row")
    let dumbellRowExercise = WorkoutExercise()
    dumbellRowExercise.exercise = dumbellRow
    dumbellRowExercise.sets = [Set(label: "Set 1", reps: 10, weight: 60), Set(label: "Failed 1", reps: 12, weight: 70), Set(label: "Set 2", reps: 7, weight: 70)]
    
    let benchPress = Exercise(name: "Bench press")
    let benchPressExercise = WorkoutExercise()
    benchPressExercise.exercise = benchPress
    benchPressExercise.sets = [Set(label: "Warmup 1", reps: 6, weight: 80), Set(label: "Set 1", reps: 5, weight: 90), Set(label: "Set 2", reps: 3, weight: 90)]
    
    workout.exercies = [dumbellRowExercise, benchPressExercise]
    
    prepopulateExercises(context: container.mainContext)
    
    return NavigationStack {
        ActiveWorkoutView(workout: workout)
            .modelContainer(container)
    }
}
