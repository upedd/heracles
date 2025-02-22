//
//  ActiveWorkoutExerciseView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 19/02/2025.
//

import SwiftUI
import CustomKeyboardKit
import SwiftData

struct KeyboardButtonStyle: ButtonStyle {
    var secondary = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 8)
            .font(.system(size: 25))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Material.regular)
            .brightness(configuration.isPressed == secondary ? 0.25 : 0.1)
            .foregroundColor(.primary)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .shadow(radius: 0, y: 1)
            .symbolVariant(configuration.isPressed ? .fill : .none)
            .animation(.default.speed(10), value: configuration.isPressed)
            .contentShape(Rectangle())
    }
}

struct DoneKeyboardButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        if configuration.isPressed {
            configuration.label
                .padding(.vertical, 8)
                .font(.body)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Material.regular)            .foregroundColor(.primary)
                .brightness(0.1)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .shadow(radius: 0, y: 1)
                .symbolVariant(configuration.isPressed ? .fill : .none)
                .animation(.default.speed(10), value: configuration.isPressed)
                .contentShape(Rectangle())
        } else {
            configuration.label
                .padding(.vertical, 8)
                .font(.body)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.blue)            .foregroundColor(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .shadow(radius: 0, y: 1)
                .symbolVariant(configuration.isPressed ? .fill : .none)
                .animation(.default.speed(10), value: configuration.isPressed)
                .contentShape(Rectangle())
        }
        
    }
}

struct BorderlessKeyboardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 8)
            .font(.system(size: 25))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundColor(.primary)
            .symbolVariant(configuration.isPressed ? .fill : .none)
            .animation(.default.speed(5), value: configuration.isPressed)
            .contentShape(Rectangle())
    }
}

extension CustomKeyboard {
    static let yesnt = CustomKeyboardBuilder { textDocumentProxy, submit, playSystemFeedback in
        VStack {
            HStack {
                Button("1") {
                    textDocumentProxy.insertText("1")
                    playSystemFeedback?()
                }
                Button("2") {
                    textDocumentProxy.insertText("2")
                    playSystemFeedback?()
                }
                Button("3") {
                    textDocumentProxy.insertText("3")
                    playSystemFeedback?()
                }
                Button {
                    playSystemFeedback?()
                    
                } label: {
                    Label("percent", systemImage: "percent")
                }
                .labelStyle(.iconOnly)
                .buttonStyle(KeyboardButtonStyle(secondary: true))
            }
            HStack {
                Button("4") {
                    textDocumentProxy.insertText("4")
                    playSystemFeedback?()
                }
                Button("5") {
                    textDocumentProxy.insertText("5")
                    playSystemFeedback?()
                }
                Button("6") {
                    textDocumentProxy.insertText("6")
                    playSystemFeedback?()
                }
                Button {
                    playSystemFeedback?()
                    
                } label: {
                    Label("previous", systemImage: "arrow.backward")
                }
                .labelStyle(.iconOnly)
                .buttonStyle(KeyboardButtonStyle(secondary: true))
            }
            HStack {
                Button("7") {
                    textDocumentProxy.insertText("7")
                    playSystemFeedback?()
                }
                Button("8") {
                    textDocumentProxy.insertText("8")
                    playSystemFeedback?()
                }
                Button("9") {
                    textDocumentProxy.insertText("9")
                    playSystemFeedback?()
                }
                Button {
                    playSystemFeedback?()
                    
                } label: {
                    Label("next", systemImage: "arrow.forward")
                }
                .labelStyle(.iconOnly)
                .buttonStyle(KeyboardButtonStyle(secondary: true))
            }
            HStack {
                Button(".") {
                    textDocumentProxy.insertText(".")
                    playSystemFeedback?()
                }
                .buttonStyle(BorderlessKeyboardButtonStyle())
                Button("0") {
                    textDocumentProxy.insertText("0")
                    playSystemFeedback?()
                }
                Button {
                    textDocumentProxy.deleteBackward()
                    playSystemFeedback?()
                } label: {
                    Label("delete", systemImage: "delete.left")
                }
                .buttonStyle(BorderlessKeyboardButtonStyle())
                .fontWeight(.light)
                .labelStyle(.iconOnly)
                Button {
                    playSystemFeedback?()
                    
                } label: {
                    Text("done")
                }
                .buttonStyle(DoneKeyboardButton())
            }.fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 6)
        .padding(.top, 6)
        .padding(.bottom, 45)
        .background(Material.thick)
        .buttonStyle(KeyboardButtonStyle())
    }
}

struct ActiveWorkoutExerciseView: View {
    
    struct SetRow: View {
        struct Input<E> : View {
            var label: String
            @Binding var value: E
            
            var body: some View {
                TextField(label, value: $value, formatter: NumberFormatter())
                    .frame(width: 50)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 3)
                    .multilineTextAlignment(.center)
                    .background(Material.regular)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .customKeyboard(.yesnt)
            }
        }
        
        @Bindable var set: WorkoutSet
        var idx: Int
        
        
        @Environment(\.editMode) var editMode
        
        var body: some View {
            HStack(alignment: .center) {
                Button {
                    set.completed.toggle()
                } label: {
                    switch(set.type) {
                    case .working:
                        Image(systemName: set.completed ? "\(idx).circle.fill" : "\(idx).circle")
                            .foregroundStyle(set.completed ? .green : .accentColor)
                    case .warmup:
                        Image(systemName: set.completed ? "w.circle.fill" : "w.circle")
                            .foregroundStyle(set.completed ? .orange : .accentColor)
                    case .cooldown:
                        Image(systemName: set.completed ? "c.circle.fill" : "c.circle")
                            .foregroundStyle(set.completed ? .cyan : .accentColor)
                    }
                }.buttonStyle(.borderless)
                    .imageScale(.large)
                    .contextMenu {
                        Picker("Set Type", selection: $set.type) {
                            ForEach(SetType.allCases, id: \.rawValue) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                    }
                    .padding(.trailing, 5)
                    .sensoryFeedback(set.completed ? .decrease : .increase, trigger: set.completed)
                
                Group {
                    Input(label: "weight", value: $set.weight)
                    Text("kg")
                    Text("×")
                    Input(label: "reps", value: $set.reps)
                }
                .opacity(set.completed ? 0.5 : 1)
            }
            .padding(.vertical, 2)
            .font(.system(.body, design: .rounded, weight: .medium))
            .alignmentGuide(.listRowSeparatorLeading) { _ in
                40
            }
        }
    }
    
    struct AddSetButton : View {
        @Bindable var exercise: WorkoutExercise
        var body: some View {
            Button {
                exercise.sets.append(.init(reps: 0, weight: 0))
            } label: {
                HStack(alignment: .center) {
                    Image(systemName: "plus")
                        .imageScale(.large)
                        .padding(.leading, 1)
                        .padding(.trailing, 10)
                    
                    Text("Add Set")
                }
                .padding(.vertical, 2)
                .font(.system(.body, design: .rounded, weight: .medium))
                
            }
        }
    }
    
    struct RecentsItem: View {
        var exercise: WorkoutExercise
        
        var body : some View {
            HStack(alignment: .top) {
                VStack {
                    ForEach(exercise.sets) { set in
                        Text("\(set.weight!.formatted()) kg × \(set.reps!)")
                    }
                }
                Spacer()
                Text(exercise.workout!.date.formatted())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    @Bindable var exercise: WorkoutExercise
    
    var setsWithIdx: [(WorkoutSet, Int)] {
        var idx = 0
        return exercise.sets.map { set in
            if set.type == .working {
                idx += 1
            }
            return (set, idx)
        }
    }
    @State var editMode: EditMode = .inactive
    @State var testValue: Double = 0
    
    // TODO: better query, better name!
    @Query var workoutExercises: [WorkoutExercise]
    var currentExerciseWorkoutExercises: [WorkoutExercise] {
        workoutExercises.filter {
            $0.exercise == exercise.exercise
        }
    }
    
    @State var showInfoSheet = false
    
    var body: some View {
        List {
//            Section("Pinned notes") {
//                ForEach(exercise.exercise.pinnedNotes) { note in
//                    Text(note.text)
//                }
//            }
            
            Section("Sets") {
                ForEach(setsWithIdx, id: \.0) { set, idx in
                    SetRow(set: set, idx: idx)
                }
                .onDelete(perform: { indexSet in
                    exercise.sets.remove(atOffsets: indexSet)
                })
                .onMove(perform: { indices, newOffset in
                    exercise.sets.move(fromOffsets: indices, toOffset: newOffset)
                })
                AddSetButton(exercise: exercise)
            }
            if !currentExerciseWorkoutExercises.isEmpty {
                Section("Recents") {
                    ForEach(currentExerciseWorkoutExercises.prefix(5)) { w in
                        RecentsItem(exercise: w)
                    }
                }
            }
        }
        .sheet(isPresented: $showInfoSheet) {
            NavigationStack {
                ExerciseView(exercise: exercise.exercise)
            }
        }
        .navigationTitle(exercise.exercise.name)
        .toolbarTitleDisplayMode(.inline)
        .environment(\.defaultMinListRowHeight, 0)
        .environment(\.editMode, $editMode)
        .toolbar {
            Button {
                showInfoSheet.toggle()
            } label: {
                Label("Info", systemImage: "info.circle")
            }
            Menu {
                
            } label: {
                Label("More", systemImage: "ellipsis.circle")
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Workout.self, configurations: config)
    let exercise = Exercise(name: "Bench Press", type: .weight_reps, primaryMuscleGroup: .chest, secondaryMuscleGroups: [.triceps, .front_delts])
    
    exercise.instructions = "Lie flat on a bench with feet firmly on the ground.\nGrip the barbell slightly wider than shoulder-width apart.\nUnrack the barbell and hold it straight above your chest with arms fully extended.\nLower the barbell slowly to your mid-chest, keeping elbows at a 45-degree angle.\nPause briefly when the barbell touches your chest.\nPush the barbell back up to the starting position, exhaling as you press.\nLock out your arms at the top and repeat for desired reps.\nRack the barbell safely after completing your set."
    
    exercise.pinnedNotes = [
        ExerciseNote(text: "Keep your back flat on the bench"),
        ExerciseNote(text: "Don't flare your elbows out"),
        ExerciseNote(text: "Use a spotter for heavy weights")
    ]
    
    exercise.youtubeVideoURL = "https://www.youtube.com/watch?v=U5zrloYWwxw"
    
    let workout_exercise = WorkoutExercise(exercise: exercise, sets: [
        .init(reps: 8, weight: 60),
        .init(reps: 8, weight: 70),
        .init(reps: 6, weight: 70)
    ])
    
    let workout_exercises: [WorkoutExercise] = [
        .init(exercise: exercise, sets: [
            .init(reps: 8, weight: 60),
            .init(reps: 8, weight: 70),
            .init(reps: 6, weight: 70)
        ]),
        .init(exercise: exercise, sets: [
            .init(reps: 8, weight: 60),
            .init(reps: 8, weight: 70),
            .init(reps: 6, weight: 70)
        ]),
        .init(exercise: exercise, sets: [
            .init(reps: 8, weight: 60),
            .init(reps: 8, weight: 70),
            .init(reps: 6, weight: 70)
        ]),
    ]
    
    for workout_exercise in workout_exercises {
        workout_exercise.workout = Workout(date: Date())
        container.mainContext.insert(workout_exercise)
    }
    
    return NavigationStack {
        ActiveWorkoutExerciseView(exercise: workout_exercise)
    }
    .modelContainer(container)
}
