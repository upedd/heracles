//
//  WorkoutView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 24/02/2025.
//

import SwiftUI
import Charts


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

extension Workout {
    func getMuscleGroupDistribution() -> [(group: MuscleGroup, value: Double)] {
        // TODO this is temp!
        var distribution: [MuscleGroup: Double] = [:]
        for exercise in exercises {
            for muscle in exercise.exercise.primaryMuscles {
                distribution[muscle_to_group[muscle]!, default: 0] += 1
            }
        }
        let total = distribution.values.reduce(0, +)
        let result = distribution.map { (group: $0.key, value: $0.value / total) }
        return result
    }
}

// FIXME: random changes when exericses are distributted equally!
struct WorkoutIconView : View {
    var workout: Workout
    
    var colors: [Color] {
        let distribution = workout.getMuscleGroupDistribution()
        return distribution
            .sorted(by: {$0.value > $1.value})
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

// TODO: more statistics about muscles
// TODO: tweak visuals
// TODO: name!!!!?!?!
struct WorkoutExerciseLinkLink : View {
    var exercise: WorkoutExercise
    
    var body : some View {
        NavigationLink {
            WorkoutExerciseView(exercise: exercise, active: false)
        } label: {
            VStack(alignment: .leading) {
                Text(exercise.exercise.name)
                    .font(.body)
                ForEach(exercise.sets) { set in
                    Text(set.formatted)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct WorkoutView: View {
    var workout: Workout
    @State private var isEditing = false
    @State private var showWorkoutInfoEditor = false
    @State private var isAddingExercises = false
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext

    @State private var showDeleteAlert = false
    var body: some View {
        
            List {
                HStack(alignment: .top){
                    WorkoutIconView(workout: workout)
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
                            Text("400kg") // TODO: calculate
                                .font(.system(.title, design: .rounded))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Muscle Groups")
                                .font(.body)
                            WorkoutMuscleDistributionChart(data: workout.getMuscleGroupDistribution())
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
                    ForEach(workout.exercises) { exercise in
                        WorkoutExerciseLinkLink(exercise: exercise)
                    }
                    .onDelete { indexSet in
                        workout.exercises.remove(atOffsets: indexSet)
                    }
                    .onMove { indexSet, newOffset in
                        workout.exercises.move(fromOffsets: indexSet, toOffset: newOffset)
                    }
                    if isEditing {
                        Button {
                            isAddingExercises.toggle()
                        } label: {
                            Label("Add Exercises", systemImage: "plus")
                        }
                        .sheet(isPresented: $isAddingExercises) {
                            SelectExercisesView(onDone: { selected in
                                for exercise in selected {
                                    workout.exercises.append(WorkoutExercise(exercise: exercise))
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
         WorkoutView(workout: Workout.sample)
    }
}
