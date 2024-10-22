//
//  WorkoutView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 08/10/2024.
//

import SwiftUI
import SwiftData


struct WorkoutInfoSheet : View {
    @Bindable var workout: Workout
    @State private var name: String
    @State private var date: Date
    @State private var selectedHours = 0
    @State private var selectedMinutes = 0
    @State private var selectedSeconds = 0
    
    init(workout: Workout) {
        print(workout)
        self.workout = workout
        self.name = workout.name
        self.date = workout.date
        
    }
    
    @State private var showDiscardWarning = false
    @State private var showDurationSelector = false
    
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                }
                Section {
                    DatePicker("Start Time", selection: $date)
                    HStack {
                        Text("Duration")
                        Spacer()
                        Button {
                            showDurationSelector = true
                        } label: {
                            Text(makeDuration().formatted(.time(pattern: .hourMinuteSecond)))
                        }.popover(isPresented: $showDurationSelector) {
                            DurationPicker(selectedHours: $selectedHours, selectedMinutes: $selectedMinutes, selectedSeconds: $selectedSeconds)
                                .presentationCompactAdaptation(.popover)
                        }
                        .buttonStyle(.bordered)
                        .foregroundStyle(.primary)
                    }
                }
            }
            .navigationTitle("Workout Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .cancellationAction) {
                    Button("Cancel") {
                        if workout.name == name && workout.date == date && workout.duration == makeDuration() {
                            dismiss()
                        } else {
                            showDiscardWarning = true
                        }
                    }
                }
                
                ToolbarItemGroup(placement: .confirmationAction) {
                    Button("Done") {
                        workout.name = name
                        workout.date = date
                        workout.duration = makeDuration()
                        dismiss()
                    }
                }
            }
            .confirmationDialog("Discard Changes", isPresented: $showDiscardWarning, titleVisibility: .hidden) {
                Button("Discard Changes", role: .destructive) {
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            }
            .onAppear {
                if workout.duration != nil {
                    // TODO: more elegant code!
                    let seconds = Int(workout.duration!.components.seconds)
                    selectedHours = seconds / 3600
                    selectedMinutes = (seconds % 3600) / 60
                    selectedSeconds = seconds % 60
                }
            }
            
        }
    }
    
    func makeDuration() -> Duration {
        Duration(secondsComponent: Int64(selectedSeconds + 60 * selectedMinutes + 3600 * selectedHours), attosecondsComponent: 0)
    }
}

struct WorkoutView: View {
    @Bindable var workout: Workout
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State var editMode: EditMode = .inactive
    @State var showInfoSheet = false
    @State var showDeleteWarning = false
    
    var body: some View {
        if editMode == .inactive {
            VStack {
                List {
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "calendar")
                                .imageScale(.small)
                            Text(workout.date, format: .dateTime.weekday(.wide).day().month(.wide))
                        }
                        .foregroundStyle(.secondary)
                        if workout.duration != nil { // Note: Possibly remove
                            HStack {
                                Image(systemName: "clock")
                                    .imageScale(.small)

                                Text(workout.duration!.formatted(.time(pattern: .hourMinuteSecond)))
                            }
                            .foregroundStyle(.secondary)
                        }
                    }
                    .listRowSeparator(.hidden)
                    .padding(.horizontal, 20)
                    ForEach(workout.exercies) { exercise in
                        DisclosureGroup {
                            ForEach(exercise.sets) { set in
                                HStack() {
                                    Text(set.label)
                                        .font(.headline)
                                    Spacer()
                                    HStack(alignment: .firstTextBaseline) {
                                        
                                        Text(set.reps!, format: .number)
                                            .font(.title.bold())
                                            .fontWeight(.medium)
                                        Text("reps")
                                            .fontWeight(.medium)
                                            .textCase(.uppercase)
                                            .foregroundStyle(.secondary)
                                            .padding(.leading, -7)
                                    }
                                    Divider()
                                        .padding(.horizontal, 10)
                                    HStack(alignment: .firstTextBaseline) {
                                        Text(set.weight!, format: .number)
                                            .font(.title)
                                            .fontWeight(.medium)
                                        Text("kg")
                                            .textCase(.uppercase)
                                            .foregroundStyle(.secondary)
                                            .padding(.leading, -7)
                                            .fontWeight(.medium)
                                    }
                                    
                                }
                                .padding()
                                .background(Material.regular)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                            }
                        } label: {
                            Text(exercise.exercise?.name ?? "Unknown exercise")
                                .font(.title2.bold())
                        }
                        .disclosureGroupStyle(MyDisclosureStyle())
                    }.listRowSeparator(.hidden)
                }
                .listRowSeparator(.visible, edges: [.top, .bottom])
                .listStyle(.inset)
                .padding(.horizontal, -20)
            }
            .navigationTitle(workout.name)
            .toolbar {
                Button("Share", systemImage: "square.and.arrow.up") {
                    // TODO: add sharing
                }
                .labelStyle(.iconOnly)
                Menu {
                    Button("Workout Info", systemImage: "info.circle") {
                        showInfoSheet = true
                    }
                    Button("Edit Exercises", systemImage: "pencil.and.list.clipboard") {
                        editMode = .active
                    }
                    Section {
                        Button("Delete Workout", systemImage: "trash", role: .destructive) {
                            showDeleteWarning = true
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            .sheet(isPresented: $showInfoSheet) {
                WorkoutInfoSheet(workout: workout)
            }
            .alert("Are you sure you want to delete this workout?", isPresented: $showDeleteWarning) {
                Button("Discard", role: .destructive) {
                    modelContext.delete(workout)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {
                    
                }
            }
        } else {
            // TODO: think about this
            ActiveWorkoutExercisesEditor(workout: workout, editMode: $editMode) {} toolbarContent: {
                EditButton()
            }
            .environment(\.editMode, $editMode)
            .navigationTitle("Editing Exercises")
            .navigationBarTitleDisplayMode(.inline)
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
    workout.duration = Duration(secondsComponent: 60 * 60 + 114, attosecondsComponent: 0)
    
    prepopulateExercises(context: container.mainContext)
    
    return NavigationStack {
        WorkoutView(workout: workout)
    }
}
