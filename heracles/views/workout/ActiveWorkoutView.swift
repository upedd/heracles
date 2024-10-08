//
//  ActiveWorkoutView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 04/10/2024.
//

import SwiftUI
import SwiftData
import Foundation


// TODO: bodyweight
// TODO: cardio
// TODO: supersets
// TODO: warmup sets
// TODO: dropsets
// TODO: percentages and rpe

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
    
    @State private var selectedExercises = Swift.Set<Exercise>()
    
    @State private var showNewExercise = false
    @State private var path = NavigationPath()
    var body: some View {
        NavigationStack(path: $path) {
            List(filteredExercises, id: \.self, selection: $selectedExercises) { exercise in
                HStack {
                    Text(exercise.name)
                    Spacer()
                    Button("Information", systemImage: "info.circle") {
                        path.append(exercise)
                    }.labelStyle(.iconOnly)
                        .buttonStyle(.borderless) // NOTE: button style must be set in order to support multiple buttons on the same row for some reason

                }
                
            }
            .navigationTitle("Select Exercises")
            .toolbar {
                ToolbarItemGroup(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("New Exercise", systemImage: "plus") {
                        showNewExercise = true
                    }
                    .labelStyle(.iconOnly)
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Add Selected (\(selectedExercises.count))") {
                        // TODO: should add items in selected order
                        for exercise in selectedExercises {
                            addExercise(exercise: exercise)
                        }
                        dismiss()
                    }.disabled(selectedExercises.count == 0)
                }
            }
            .environment(\.editMode, Binding.constant(EditMode.active))
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showNewExercise) {
                NewExerciseView()
            }
            .searchable(text: $searchText)
            .navigationDestination(for: Exercise.self) { exercise in
                ExerciseView(exercise: exercise)
            }
        }
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

struct ExerciseFocusState: Hashable {
    var set: Set
    var fieldIdx: Int
}

struct ActiveWorkoutSet: View {
    @FocusState.Binding var focusState: ExerciseFocusState?
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
                .focused($focusState, equals: .init(set: set, fieldIdx: 0))
            Spacer()
            TextField("", value: $set.reps, format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .frame(maxWidth: textFieldWidth)
                .disabled(set.completed)
                .accessibilityLabel("reps")
                .focused($focusState, equals: .init(set: set, fieldIdx: 1))
            TextField("", value: $set.weight, format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .frame(maxWidth: textFieldWidth)
                .disabled(set.completed)
                .accessibilityLabel("weight")
                .focused($focusState, equals: .init(set: set, fieldIdx: 2))
        }
    }
    
    
}

struct ActiveWorkoutExerciseView: View {
    @FocusState.Binding var focusState: ExerciseFocusState?
    @Bindable var exercise: WorkoutExercise
    
    var body: some View {
        DisclosureGroup {
            ActiveWorkoutExerciseSetHeader()
            ForEach(exercise.sets) { set in
                ActiveWorkoutSet(focusState: $focusState, set: set)
                    .listRowSeparator(.visible)
            }
            .onMove(perform: move)
            .onDelete(perform: delete)
            ActiveWorkoutNewSet(exercise: exercise)
        } label: {
            Text(exercise.exercise?.name ?? "Unknown exercise")
                .font(.title2.bold())
        }
        .disclosureGroupStyle(MyDisclosureStyle())
    }
    
    func move(from source: IndexSet, to destination: Int) {
        exercise.sets.move(fromOffsets: source, toOffset: destination)
    }
    func delete(idx: IndexSet) {
        exercise.sets.remove(atOffsets: idx)
    }
}


struct ActiveWorkoutView : View {
    @Bindable var workout: Workout
    var durationDisplay: String = ""
    @State private var isExpanded = Swift.Set<WorkoutExercise>()
    @State private var showAddExercise: Bool = false
    @State var editMode = EditMode.inactive
    @FocusState var focusState: ExerciseFocusState?
    
    var body: some View {
        VStack {
            List { // TODO: spacing issues!
                VStack(alignment: .leading) {
                    Text(workout.date, format: .dateTime.weekday(.wide).day().month(.abbreviated))
                        .font(.footnote.bold())
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    Text(workout.name)
                        .font(.largeTitle.bold())
                        
                }.padding()
                ForEach(workout.exercies) { exercise in
                    ActiveWorkoutExerciseView(focusState: $focusState, exercise: exercise)
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
        .navigationTitle(durationDisplay)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddExercise) {
            AddExerciseDialog(workout: workout)
        }
        .toolbar {
            if focusState != nil {
                Button("Done", role: .cancel) {
                    focusState = nil
                }
            } else if editMode.isEditing {
                Button("Done", role: .cancel) {
                    editMode = .inactive
                }
            } else {
                Menu {
                    Button("Edit", systemImage: "pencil") {
                        editMode = .active
                    }
                    Section {
                        Button("Cancel Workout", systemImage: "trash", role: .destructive) {}
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                Button("Finish") {}
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
            }
            //
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Next") {
                    nextField()
                }
            }
        }
        .onDisappear {
            editMode = .inactive
        }
        .environment(\.editMode, $editMode)
    }
    
    func nextField() {
        guard focusState != nil else {
            return
        }
        print("next")
        var focusState = focusState!
        focusState.fieldIdx += 1
        print(focusState)
        if (focusState.fieldIdx == 3) {
            let sets = focusState.set.workoutExercise?.sets
            let idx = sets?.firstIndex(of: focusState.set)
            guard sets != nil && idx != nil && idx! + 1 != sets!.count  else {
                self.focusState = nil
                return
            }
            print("next next")
            focusState = .init(set: sets![idx! + 1], fieldIdx: 1)
        }
        self.focusState = focusState
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
