//
//  ActiveWorkoutView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 13/02/2025.
//

import SwiftUI
import SwiftData

// TODO: add recents
// TODO: add favorites
// TODO: match functionality with exercise list
struct SelectExercisesView: View {
    
    struct Item: View {
        var exercise: Exercise
        var isSelected: Bool
        var onInfoClicked: () -> Void
        var body : some View {
            HStack {
                // TODO: fix selection highlight
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .symbolRenderingMode(.multicolor)
                    .foregroundStyle(isSelected ? Color.accentColor : Color(.tertiaryLabel), Color.primary)
                    .imageScale(.large)
                Text(exercise.name)
                    .foregroundStyle(Color.primary)
                    .multilineTextAlignment(.leading)
                Spacer()
                Button {
                    onInfoClicked()
                } label: {
                    Image(systemName: "info.circle")
                        .imageScale(.large)
                }
            }
            .padding(.vertical, 5)
            
        }
    }
    
    @Query private var exercises: [Exercise]
    @State private var selection = Set<Exercise>()
    @State private var searchText = ""
    @Environment(\.dismiss) var dismiss
    @StateObject private var tableData = TableViewData<Exercise>() // Holds
    @State private var selectedEquipment: Set<Equipment> = .init( Equipment.allCases)
    
    @State private var selectedMuscles: Set<Muscle> = .init(Muscle.allCases)
    @State private var showFilters = false
    @State private var showInfo = false
    @State private var showExercise: Exercise? = nil
    
    var onDone: (Set<Exercise>) -> Void
    
    enum Grouping: String, CaseIterable, Equatable {
        case name
        case muscle
        case equipment
    }
    
    @State private var grouping: Grouping = .name
    
    var body: some View {
        NavigationStack {
            VStack {
                TableViewWrapper(data: tableData, onSelect: onSelect) { item in
                    Item(exercise: item, isSelected: isSelected(item), onInfoClicked: {
                        showExercise = item
                        showInfo.toggle()
                    })
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .edgesIgnoringSafeArea(.all)
            .onAppear { updateGroupedExercises() }
            .environment(\.editMode, .constant(EditMode.active))
            .navigationTitle(selection.isEmpty ? "Select Exercises" : "\(selection.count) Selected")
            .sheet(isPresented: $showInfo) {
                NavigationStack {
                    // FIXME: prevent this from flashing empty on sheet open!
                    if let showExercise {
                        ExerciseView(exercise: showExercise)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button {
                                        showInfo.toggle()
                                    } label: {
                                        Text("Done")
                                    }
                                    
                                }
                            }
                    }
                }
            }
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
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    
                    Menu {
                        Button {
                            showFilters.toggle()
                        } label: {
                            Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                        }
                        .labelStyle(.iconOnly)
                        Menu {
                            Picker("Grouping", selection: $grouping) {
                                ForEach(Grouping.allCases, id: \.self) { grouping in
                                    Text(grouping.rawValue.capitalized).tag(grouping)
                                }
                            }
                        } label: {
                            Label("Group By", systemImage: "list.bullet")
                            Text(grouping.rawValue.capitalized)
                        }
                        
                        
                        
                        
                    } label: {
                        Label("More", systemImage: "ellipsis.circle")
                    }
                    Spacer()
                    Button {
                        // TODO: STUB
                    } label: {
                        Label("Add Exercise", systemImage: "plus")
                    }
                }
                
            }
            .sheet(isPresented: $showFilters) {
                ExerciseFilterSheet(selectedEquipment: $selectedEquipment, selectedMuscles: $selectedMuscles)
            }
            .onChange(of: exercises) {updateGroupedExercises() }
            .onChange(of: searchText) { updateGroupedExercises() }
            .onChange(of: selectedEquipment) {updateGroupedExercises() }
            .onChange(of: grouping) {updateGroupedExercises() }
            .searchable(text: $searchText)
        }
    }
    private func onSelect(_ exercise: Exercise) {
        if selection.contains(exercise) {
            selection.remove(exercise)
        } else {
            selection.insert(exercise)
        }
    }
    
    private func isSelected(_ exercise: Exercise) -> Bool {
        selection.contains(exercise)
    }
    
    private func updateGroupedExercises() {
        let filtered = exercises
            .filter { exercise in
                searchText.isEmpty || exercise.name.localizedCaseInsensitiveContains(searchText)
            }
            .filter { exercise in
                selectedEquipment.contains(where: { equipment in
                    exercise.equipment.contains(equipment)
                })
            }
            .sorted { $0.name < $1.name }
        if grouping == .name {
            
            let dict = Dictionary(grouping: filtered, by: { String($0.name.prefix(1)) })
            let sorted = dict.sorted { $0.key < $1.key }.map { (title: $0.key, items: $0.value) }
            
            tableData.sections = sorted // Trigger UI update
        } else if grouping == .muscle {
            // TODO: better grouping?!!?!!
            let dict = Dictionary(grouping: filtered, by: { $0.primaryMuscles.first!.displayName() })
            let sorted = dict.sorted { $0.key < $1.key }.map { (title: $0.key, items: $0.value) }
            tableData.sections = sorted
        }else if grouping == .equipment {
            let dict = Dictionary(grouping: filtered, by: { $0.equipment.first!.displayName() })
            let sorted = dict.sorted { $0.key < $1.key }.map { (title: $0.key, items: $0.value) }
            tableData.sections = sorted
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
    
    @Query private var workoutExercises: [WorkoutExercise]
    
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
                            WorkoutExerciseView(exercise: exercise, active: true)
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
                    .sheet(isPresented: $isAddingExercises) {
                        SelectExercisesView(onDone: { selected in
                            for exercise in selected {
                                let workoutExercise = WorkoutExercise(exercise: exercise)
                                // TODO: check
                                let lastWorkoutExercise = workoutExercises.filter {
                                    $0.exercise == exercise && $0.workout! != workout && !$0.workout!.active
                                }.sorted {
                                    $0.workout!.date > $1.workout!.date
                                }.first
                                
                                if let lastWorkoutExercise {
                                    for set in lastWorkoutExercise.sets {
                                        workoutExercise.sets.append(WorkoutSet(reps: set.reps, weight: set.weight, time: set.time, distance: set.distance))
                                    }
                                }
                                
                                workout.exercises.append(workoutExercise)
                            }
                        })
                    }
                }
                
            }
            .toolbar {
                EditButton()
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
                    workout.endDate = Date.now
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
    ActiveWorkoutView(workout: workout, timerManager: .make(id: "preview"))
        .modelContainer(for: [Exercise.self, Plate.self, Barbell.self], inMemory: true) { result in
            do {
                let container = try result.get()
                preloadExercises(container)
                preloadBarbells(container)
                preloadPlates(container)
            } catch {
                print("Failed to create model container.")
            }
        }
}
