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
    @Bindable var set: Set
    var icon: String
    
    func makeBody(configuration: Configuration) -> some View {
        Menu {
            Button {
                set.isWarmup = false
            } label: {
                Label("Working Set", systemImage: "number.circle")
            }
            Button {
                set.isWarmup = true
            } label: {
                Label("Warmup Set", systemImage: "w.circle")
            }
        } label: {
            Label {
                
            } icon: {
                Image(systemName: configuration.isOn ? "\(icon).circle.fill" : "\(icon).circle")
                    .foregroundStyle(configuration.isOn ? Color.accentColor : .secondary)
                    .accessibility(label: Text(configuration.isOn ? "Checked" : "Unchecked"))
                    .imageScale(.large)
            }
        } primaryAction: {
            configuration.isOn.toggle()
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
            .buttonStyle(.plain)
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
        }
        if configuration.isExpanded {
            configuration.content
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
    var idx: Int
    @ScaledMetric private var textFieldWidth = 70
    
    var body: some View {
        
            Toggle("Completed", isOn: $set.completed)
                .toggleStyle(CheckToggleStyle(set: set, icon: set.isWarmup ? "w" : "\(idx + 1)"))
                .labelsHidden()
                .sensoryFeedback(.success, trigger: set.completed)
                .frame(maxWidth: textFieldWidth)
            Spacer()
            Text("10x30kg")
                .font(.subheadline)
                .frame(maxWidth: textFieldWidth)
            Spacer()
            TextField("", value: $set.reps, format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .frame(maxWidth: textFieldWidth)
                .accessibilityLabel("reps")
                .focused($focusState, equals: .init(set: set, fieldIdx: 1))
                .multilineTextAlignment(.center)
            Spacer()
            TextField("", value: $set.weight, format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .frame(maxWidth: textFieldWidth)
                .accessibilityLabel("weight")
                .focused($focusState, equals: .init(set: set, fieldIdx: 2))
                .multilineTextAlignment(.center)
    }
    
    
}

struct MyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        GridRow {
            configuration.label
        }
    }
}


// TODO: needs some tweaking on wider screens

struct ActiveWorkoutExerciseView: View {
    @FocusState.Binding var focusState: ExerciseFocusState?
    @Bindable var exercise: WorkoutExercise
    @Environment(\.editMode) var editMode
    @ScaledMetric private var textFieldWidth = 70
    
    @State var showDetailsSheet = false
    
    // TODO: make functional!
    @State var weightUnit = 0
    @State var trackRpe = 0
    @State var autoRestTimer = 0
    var body: some View {
        DisclosureGroup(isExpanded: $exercise.expanded) {
                HStack() {
                    // header!
                    Color.clear.frame(width: 0, height: 0)
                        .frame(maxWidth: textFieldWidth)
                    Spacer()
                    Text("previous")
                        .frame(maxWidth: textFieldWidth)
                    Spacer()
                    Text("reps")
                        .frame(width: textFieldWidth)
                    Spacer()
                    Text("weight (kg)")
                        .frame(width: textFieldWidth)
                }.font(.caption)
                    .foregroundStyle(.secondary)
                // TODO: ensure warmup sets at beginning
                ForEach(Array(exercise.sets.enumerated()), id: \.element) { idx, set in
                    HStack {
                        ActiveWorkoutSet(focusState: $focusState, set: set, idx: idx)
                    }
                    .overlay(Divider().padding(.horizontal, -40).offset(y: 15), alignment: .bottom)
                }
                
                .onMove(perform: move)
                .onDelete(perform: delete)
                
                Button {
                    exercise.sets.append(Set(label: ""))
                } label: {
                    Label {
                        
                    } icon: {
                        Image(systemName: "plus.circle")
                            .imageScale(.large)
                    }
                }.buttonStyle(.plain)
                    .foregroundStyle(.accent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 12)
                    .padding(.top, 5)
        } label: {
            HStack(alignment: .center) {
                Text(exercise.exercise?.name ?? "Unknown exercise")
                    .font(.title2.bold())
                Spacer()
                Menu("Exercise Menu", systemImage: "ellipsis") {
                    Section {
                        Button("Details", systemImage: "info") {
                            showDetailsSheet = true
                        }
                        
                    }
                    Section {
                        Button("Substitute", systemImage: "rectangle.2.swap") {
                            
                        }
                        Button("Add a Note", systemImage: "square.and.pencil") {
                            
                        }
                        Button("Add Warmup Sets", systemImage: "figure.cooldown") {
                            
                        }
                    }
                    Section {
                        Menu {
                            Picker(selection: $autoRestTimer, label: Text("Auto Rest Timer")) {
                                Text("Off").tag(0)
                                Text("On").tag(1)
                            }
                        } label: {
                            Button(action: {}) {
                                Text("Auto Rest Timer")
                                Text(weightUnit == 0 ? "Off" : "On")
                                Image(systemName: "timer")
                            }
                        }
                        Menu {
                            Picker(selection: $weightUnit, label: Text("Weight Unit")) {
                                Text("kg").tag(0)
                                Text("lbs").tag(1)
                            }
                        } label: {
                            Button(action: {}) {
                                Text("Weight Unit")
                                Text(weightUnit == 0 ? "kg" : "lbs")
                                Image(systemName: "scalemass")
                            }
                        }
                        Menu {
                            Picker(selection: $trackRpe, label: Text("Track RPE")) {
                                Text("Off").tag(0)
                                Text("On").tag(1)
                            }
                        } label: {
                            Button(action: {}) {
                                Text("Track RPE")
                                Text(weightUnit == 0 ? "Off" : "On")
                                Image(systemName: "number")
                            }
                        }
                    }
                    Section {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            
                        }
                    }
                    
                }.labelStyle(.iconOnly)
                    .padding(.trailing, 10)
                
            }
        }
        .disclosureGroupStyle(MyDisclosureStyle())
        .sheet(isPresented: $showDetailsSheet) {
            ExerciseView(exercise: exercise.exercise!)
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        exercise.sets.move(fromOffsets: source, toOffset: destination)
    }
    func delete(idx: IndexSet) {
        exercise.sets.remove(atOffsets: idx)
    }
}


// For use in List!!!
struct ActiveWorkoutExercisesEditor<Content: View, ToolbarContent: View>: View {
    @Bindable var workout: Workout
    @Binding var editMode: EditMode
    @ViewBuilder let content: Content
    @ViewBuilder let toolbarContent: ToolbarContent
    @FocusState var focusState: ExerciseFocusState?
    @State private var showAddExercise: Bool = false
    
    var body: some View {
        List { // TODO: spacing issues!
            content
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
                    Spacer()
                }
                .padding(.all, 15)
                .background(Material.regular)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            //.background(Color(UIColor.systemBackground))
            .buttonStyle(.plain)
            
            .listRowSeparator(.hidden)
        }
        .listRowSeparator(.visible, edges: [.top, .bottom])
        .listStyle(.inset)
        .sheet(isPresented: $showAddExercise) {
            AddExerciseDialog(workout: workout)
        }
        .toolbar {
            if focusState != nil {
                Button("Done", role: .cancel) {
                    focusState = nil
                }
            } else if editMode.isEditing {
                EditButton()
            } else {
                toolbarContent
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Next") {
                    nextField()
                }
            }
        }
    }
    
    func nextField() {
        guard focusState != nil else {
            return
        }
        var focusState = focusState!
        focusState.fieldIdx += 1
        if (focusState.fieldIdx == 3) {
            let sets = focusState.set.workoutExercise?.sets
            let idx = sets?.firstIndex(of: focusState.set)
            guard sets != nil && idx != nil && idx! + 1 != sets!.count  else {
                self.focusState = nil
                return
            }
            focusState = .init(set: sets![idx! + 1], fieldIdx: 1)
        }
        self.focusState = focusState
    }
}

struct ActiveWorkoutView : View {
    @Bindable var workout: Workout
    var durationDisplay: String = ""
    @State private var isExpanded = Swift.Set<WorkoutExercise>()
    @State var editMode = EditMode.inactive
    @State var showFinishAlert = false
    @EnvironmentObject var ctx: AppContext
    @Environment(\.modelContext) var modelContext
    @State var showDiscardWarning = false
    
    var body: some View {
        VStack {
            ActiveWorkoutExercisesEditor(workout: workout, editMode: $editMode) {
                VStack(alignment: .leading) {
                    Text(workout.date, format: .dateTime.weekday(.wide).day().month(.abbreviated))
                        .font(.footnote.bold())
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    Text(workout.name)
                        .font(.largeTitle.bold())
                    
                }
            } toolbarContent: {
                Menu {
                    Button("Edit", systemImage: "pencil") {
                        editMode = .active
                    }
                    Section {
                        Button("Discard Workout", systemImage: "trash", role: .destructive) {
                            showDiscardWarning = true
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                Button("Finish") {
                    showFinishAlert = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)

            }
        }
        .navigationTitle(durationDisplay)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Finish Workout",isPresented: $showFinishAlert) { // TODO: message design?
            Button("Finish") {
                workout.finished = true
                ctx.activeWorkout = nil
                ctx.popupBarVisible = false
                ctx.popupBarOpen = false
                workout.duration = Duration(secondsComponent: Int64(Date.now.timeIntervalSince(workout.date)), attosecondsComponent: 0)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action is irreversible.")
        }
        .alert("Are you sure you want to discard this workout?", isPresented: $showDiscardWarning) {
            Button("Discard", role: .destructive) {
                modelContext.delete(workout)
                ctx.activeWorkout = nil
                ctx.popupBarOpen = false
                ctx.popupBarVisible = false
            }
            Button("Cancel", role: .cancel) {}
        }
        .onDisappear {
            editMode = .inactive
        }
        .environment(\.editMode, $editMode)
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
