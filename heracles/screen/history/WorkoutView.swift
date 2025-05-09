//
//  WorkoutView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 24/02/2025.
//

import SwiftUI
import Charts
import SwiftData

// design: maybe add redo workout button, but it could be bit confusing

struct WorkoutMuscleDistributionChart : View {
    var data: [(group: MuscleGroup, value: Double)]
    
    var body : some View {
        Chart(data, id: \.group) { group, value in
            Plot {
                BarMark(x: .value("Percentage", value))
                    .foregroundStyle(by: .value("Group", group.rawValue.uppercased()))
            }
        }.chartPlotStyle { plotArea in
            plotArea
#if os(macOS)
                .background(Color.gray.opacity(0.2))
#else
                .background(Color(.systemFill))
#endif
                .cornerRadius(4)
        }
        .chartXAxis(.hidden)
        .chartYScale(range: .plotDimension(endPadding: -8))
        .chartLegend(position: .bottom, spacing: 8)
        .chartLegend(.visible)
        .chartForegroundStyleScale(mapping: { value in
            for group in MuscleGroup.allCases {
                if group.rawValue.uppercased() == value {
                    return muscle_group_colors[group]!
                }
            }
            return .gray
        })
        .frame(height: 35)
    }
    
    
    
}

extension Array<WorkoutExercise> {
    func getMuscleGroupDistribution() -> [(group: MuscleGroup, value: Double)] {
        // TODO this is temp!
        var distribution: [MuscleGroup: Double] = [:]
        for exercise in self {
            for muscle in exercise.exercise.primaryMuscles {
                distribution[muscle_to_group[muscle]!, default: 0] += 1
            }
        }
        let total = distribution.values.reduce(0, +)
        let result = distribution.map { (group: $0.key, value: $0.value / total) }.sorted(by: { $0.group.rawValue < $1.group.rawValue })
        return result
    }
}

struct WorkoutIconView : View {
    var exercises: [WorkoutExercise]
    
    var colors: [Color] {
        let distribution = exercises.getMuscleGroupDistribution()
        return distribution
            .sorted(by: {
                if $0.value == $1.value {
                    return $0.group.rawValue < $1.group.rawValue
                }
                return $0.value > $1.value
            })
            .map { muscle_group_colors[$0.group]! }
    }
    
    var body: some View {
        Group {
            if colors.count >= 4 {
                MeshGradient(width: 2, height: 2, points: [
                    [0, 0], [1, 0],
                    [0, 1], [1, 1]
                ], colors: [
                    colors[0], colors[1],
                    colors[2], colors[3]
                ])
            } else if colors.count >= 2 {
                LinearGradient(colors: [colors[0], colors[1]], startPoint: .topLeading, endPoint: .bottomTrailing)
            
            } else if colors.count >= 1 {
                Rectangle().fill(colors[0].gradient)
            }
        }
        
        
    }
}

// TODO: more statistics
// TODO: name!!!!?!?!
struct WorkoutExerciseLinkLink : View {
    var exercise: WorkoutExercise
    @Environment(Settings.self) private var settings
    
    var body : some View {
        NavigationLink {
            WorkoutExerciseView(exercise: exercise, active: false)
        } label: {
            VStack(alignment: .leading) {
                Text(exercise.exercise.name)
                    .font(.body)
                ForEach(exercise.sets.sorted(by: {$0.order < $1.order})) { set in
                    Text(set.formatted(settings: settings))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct WorkoutView: View {
    var workout: Workout
    var exercises: [Exercise]
    @State private var isEditing = false
    @State private var showWorkoutInfoEditor = false
    @State private var isAddingExercises = false
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext

    @State private var showDeleteAlert = false
    @State private var showNewTemplateView = false
    
    var totalVolume: Double {
        var volume: Double = 0
        for exercise in workout.exercises {
            guard exercise.exercise.trackReps && exercise.exercise.trackWeight else {
                continue
            }
            for set in exercise.sets {
                volume += set.weight! * Double(set.reps!)
            }
        }
        return volume
    }
    
    var sortedExercises: [WorkoutExercise] {
        return workout.exercises.sorted { $0.order < $1.order }
    }
    
    @Environment(Settings.self) private var settings
    
    var body: some View {
        
            List {
                HStack(alignment: .top){
                    WorkoutIconView(exercises: workout.exercises)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.trailing, 10)
                    VStack(alignment: .leading) {
                        
                        Text(workout.name)
                            .font(.body)
                            .padding(.bottom, 10)
                        Text(workout.date...workout.endDate)
                            .font(.system(.callout, design: .rounded))
                            .foregroundStyle(.secondary)
                        
                    }
                    
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                Section {
                    HStack {
                        // TODO: more statistics depending on exercises types!
                        VStack(alignment: .leading) {
                            Text("Workout Time")
                                .font(.body)
                            Text(workout.duration.formatted)
                                .font(.system(.title, design: .rounded))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        VStack(alignment: .leading) {
                            Text("Total Volume")
                                .font(.body)
                            Text("\(totalVolume.formatted()) \(settings.weightUnit.short())")
                                .font(.system(.title, design: .rounded))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Muscle Groups")
                                .font(.body)
                            WorkoutMuscleDistributionChart(data: workout.exercises.getMuscleGroupDistribution())
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } header: {
                    Text("Workout Details")
                        .font(.title2.bold())
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        .foregroundStyle(.primary)
                        .textCase(.none)
                        .listRowInsets(EdgeInsets())
                }
                
                
                Section {
                    ForEach(sortedExercises) { exercise in
                        WorkoutExerciseLinkLink(exercise: exercise)
                    }
                    .onDelete { indexSet in
                        var updateExercises =
                        sortedExercises
                        updateExercises.remove(atOffsets: indexSet)
                        for (idx, exercise) in updateExercises.enumerated() {
                            exercise.order = idx
                        }
                        workout.exercises = updateExercises
                    }
                    .onMove { indexSet, newOffset in
                        var updateExercises = sortedExercises
                        updateExercises.move(fromOffsets: indexSet, toOffset: newOffset)
                        
                        for (idx, exercise) in updateExercises.enumerated() {
                            exercise.order = idx
                        }
                    }
                    if isEditing {
                        Button {
                            isAddingExercises.toggle()
                        } label: {
                            Label("Add Exercises", systemImage: "plus")
                        }
                        .sheet(isPresented: $isAddingExercises) {
                            SelectExercisesView(exercises: exercises, onDone: { selected in
                                for exercise in selected {
                                    workout.exercises.append(WorkoutExercise(exercise: exercise, order: workout.exercises.count))
                                }
                            })
                        }
                    }
                } header: {
                    Text("Exercises")
                        .font(.title2.bold())
                        .padding(.top, 10)
                        .padding(.bottom, 5)
                        .foregroundStyle(.primary)
                        .textCase(.none)
                        .listRowInsets(EdgeInsets())
                }
            }
            .navigationTitle(workout.date.formatted(.dateTime.weekday().day().month()))
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                if isEditing {
                    Button("Done") {
                        withAnimation {
                            isEditing.toggle()
                        }
                    }
                } else {
                    Menu {
                        Button("Show Workout Info", systemImage: "info.circle") {
                            showWorkoutInfoEditor.toggle()
                        }
                        Button("Edit Exercises", systemImage: "pencil") {
                            withAnimation {
                                isEditing.toggle()
                            }
                        }
                        Button("Save as Template", systemImage: "plus.square.on.square") {
                            showNewTemplateView.toggle()
                        }
                        Button("Delete Workout", systemImage: "trash", role: .destructive) {
                            showDeleteAlert.toggle()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showWorkoutInfoEditor) {
                NavigationStack {
                    WorkoutEditorView(workout: workout)
                }
            }
            .sheet(isPresented: $showNewTemplateView) {
                // deep copy
                let exercises: [WorkoutExercise] = workout.exercises.map { exercise in
                    let newExercise = WorkoutExercise(exercise: exercise.exercise, order: exercise.order)
                    newExercise.sets = exercise.sets.map {
                        WorkoutSet(order: $0.order, reps: $0.reps, weight: $0.weight, time: $0.time, distance: $0.distance)
                    }
                    return newExercise
                }
                NewWorkoutTemplateView(name: workout.name, workoutExercises: exercises)
            }
            .alert("Delete workout \"\(workout.name)\"?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    modelContext.delete(workout)
                    presentationMode.wrappedValue.dismiss()
                }
                
            } message: {
                Text("This action cannot be undone.")
            }
            .environment(\.editMode, .constant(isEditing ? EditMode.active : EditMode.inactive))
        
    }
}

#Preview {
     NavigationStack {
         WorkoutView(workout: Workout.sample, exercises: [])
    }
     .environment(Settings())
}
