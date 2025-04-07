//
//  ActiveWorkoutExerciseView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 19/02/2025.
//

import SwiftUI
import CustomKeyboardKit
import SwiftData

// TODO: cleanup
// FIXME: weird animation on donekeyboardbutton
// TODO: keyboard suggestions for weight and reps!

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

func roundToNearestMultiple(of multiple: Double, value: Double) -> Double {
    return (value / multiple).rounded() * multiple
}

struct ActiveWorkoutExerciseView: View {
    
    struct SetRow: View {
        @Bindable var set: WorkoutSet
        var idx: Int
        var active: Bool
        // MESS!!!
        var rawIdx: Int
        var isLast: Bool
        @FocusState.Binding var focusedField: Int?
        
        @Environment(\.editMode) var editMode
        
        static let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 2
            formatter.decimalSeparator = "."
            formatter.groupingSeparator = ","
            formatter.zeroSymbol = ""
            return formatter
        }()
        
        private var weightText: Binding<String> {
            Binding {
                if let weight = set.weight {
                    if weight == 0 {
                        return "0"
                    } else {
                        return ActiveWorkoutExerciseView.SetRow.formatter.string(from: NSNumber(value: weight)) ?? "0"
                    }
                } else {
                    return "0"
                }
            } set: { newValue in
                set.weight = Double(newValue) ?? 0
            }
        }
        
        @State private var weightTextSelection: TextSelection?
        
        
        private var setText: Binding<String> {
            Binding {
                set.reps != nil ? "\(set.reps!)" : ""
            } set: { newValue in
                set.reps = Int(newValue) ?? 0
            }
        }
        
        @State private var setTextSelection: TextSelection?
        
        var body: some View {
            HStack(alignment: .center) {
                if active {
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
                } else {
                    // TODO: what to do with failed sets?
                    Group {
                        switch(set.type) {
                        case .working:
                            Text("\(idx)")
                                .foregroundStyle(.green)
                        case .warmup:
                            Text("W")
                                .foregroundStyle(.orange)
                        case .cooldown:
                            Text("C")
                                .foregroundStyle(.cyan)
                        }
                    }
                    .frame(width: 20)
                    
                    .padding(.trailing, 10)
                    .font(.system(.body, design: .rounded, weight: .medium))
                }
                
                Group {
                    if active {
                        TextField("weight", text: weightText, selection: $weightTextSelection)
                            .frame(width: 50)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 3)
                            .multilineTextAlignment(.center)
                            .background(Material.regular)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .customKeyboard { textDocumentProxy, onSubmit, playSystemFeedback in
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
                                        // TODO: icon
                                        // TODO: add weight calculator
                                        Button {
                                            playSystemFeedback?()
                                        } label: {
                                            Label("dumbbell", systemImage: "dumbbell")
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
                                        // TODO: customization of this value
                                        // TODO: by default, should be 2.5 for barbell exercises!
                                        Button {
                                            let doubleValue = Double(weightText.wrappedValue) ?? 0
                                            weightTextSelection = nil
                                            weightText.wrappedValue = ActiveWorkoutExerciseView.SetRow.formatter.string(from: NSNumber(value: roundToNearestMultiple(of: 1.25, value: doubleValue - 1.25))) ?? "0"
                                            weightTextSelection = .init(range: weightText.wrappedValue.startIndex..<weightText.wrappedValue.endIndex)
                                            playSystemFeedback?()
                                        } label: {
                                            Label("minus", systemImage: "minus")
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
                                            let doubleValue = Double(weightText.wrappedValue) ?? 0
                                            weightTextSelection = nil
                                            weightText.wrappedValue = ActiveWorkoutExerciseView.SetRow.formatter.string(from: NSNumber(value: roundToNearestMultiple(of: 1.25, value: doubleValue + 1.25))) ?? "0"
                                            weightTextSelection = .init(range: weightText.wrappedValue.startIndex..<weightText.wrappedValue.endIndex)
                                            playSystemFeedback?()
                                        } label: {
                                            Label("plus", systemImage: "plus")
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
                                            onSubmit()
                                            playSystemFeedback?()
                                        } label: {
                                            Text("next")
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
                            .focused($focusedField, equals: rawIdx * 2)
                            .onCustomSubmit {
                                focusedField = rawIdx * 2 + 1
                            }
                            .onChange(of: focusedField) {
                                if focusedField == rawIdx * 2 {
                                    weightTextSelection = .init(range: weightText.wrappedValue.startIndex..<weightText.wrappedValue.endIndex)
                                }
                            }
                        Text("kg")
                        Text("×")
                        TextField("reps", text: setText, selection: $setTextSelection)
                            .frame(width: 50)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 3)
                            .multilineTextAlignment(.center)
                            .background(Material.regular)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .customKeyboard { textDocumentProxy, onSubmit, playSystemFeedback in
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
                                        // TODO: should we rpe on reps?
                                        Button {
                                            playSystemFeedback?()
                                        } label: {
                                            Label("dumbbell", systemImage: "dumbbell")
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
                                            let value = Int(setText.wrappedValue) ?? 0
                                            setTextSelection = nil
                                            setText.wrappedValue = "\(value - 1)"
                                            setTextSelection = .init(range: setText.wrappedValue.startIndex..<setText.wrappedValue.endIndex)
                                            playSystemFeedback?()
                                        } label: {
                                            Label("minus", systemImage: "minus")
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
                                            let value = Int(setText.wrappedValue) ?? 0
                                            setTextSelection = nil
                                            setText.wrappedValue = "\(value + 1)"
                                            setTextSelection = .init(range: setText.wrappedValue.startIndex..<setText.wrappedValue.endIndex)
                                            playSystemFeedback?()
                                        } label: {
                                            Label("plus", systemImage: "plus")
                                        }
                                        .labelStyle(.iconOnly)
                                        .buttonStyle(KeyboardButtonStyle(secondary: true))
                                    }
                                    HStack {
                                        // TODO: find better way!
                                        Button(".") {
                                            textDocumentProxy.insertText(".")
                                            playSystemFeedback?()
                                        }
                                        .buttonStyle(BorderlessKeyboardButtonStyle())
                                        .opacity(0)
                                        .accessibilityHidden(true)
                                        .disabled(true)
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
                                            onSubmit()
                                        } label: {
                                            if isLast {
                                                Text("done")
                                            } else {
                                                Text("next")
                                            }
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
                            .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                                if let textField = obj.object as? UITextField {
                                    textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                                }
                            }
                            .focused($focusedField, equals: rawIdx * 2 + 1)
                            .onCustomSubmit {
                                set.completed = true
                                if isLast {
                                    focusedField = nil
                                } else {
                                    focusedField = rawIdx * 2 + 2
                                }
                            }
                            .onChange(of: focusedField) {
                                if focusedField == rawIdx * 2 + 1 {
                                    setTextSelection = .init(range: setText.wrappedValue.startIndex..<setText.wrappedValue.endIndex)
                                }
                            }
                    } else {
                        Text("\(set.weight!.formatted()) kg × \(set.reps!)")
                            .padding(.leading, 5)
                    }
                }
                .opacity(active && set.completed ? 0.5 : 1)
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
                if let last = exercise.sets.last {
                    exercise.sets.append(.init(reps: last.reps, weight: last.weight))
                } else {
                    exercise.sets.append(.init(reps: 0, weight: 0))
                }

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
    
    // design: should link to workout?
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
    // TODO: better query, better name!
    @Query var workoutExercises: [WorkoutExercise]
    var currentExerciseWorkoutExercises: [WorkoutExercise] {
        workoutExercises.filter {
            $0.exercise == exercise.exercise && $0.workout! != exercise.workout! && !$0.workout!.active
        }
    }
    
    var active: Bool
    
    @State var showInfoSheet = false
    @State var activeState: Bool = false
    
    @FocusState var focusedField: Int?
    
    var body: some View {
        List {
            //            Section("Pinned notes") {
            //                ForEach(exercise.exercise.pinnedNotes) { note in
            //                    Text(note.text)
            //                }
            //            }
            
            Section("Sets") {
                // MESS!!!
                ForEach(Array(setsWithIdx.enumerated()), id: \.element.0) { rawIdx, element in
                    SetRow(set: element.0, idx: element.1, active: activeState, rawIdx: rawIdx, isLast: rawIdx == setsWithIdx.count - 1, focusedField: $focusedField)
                }
                .onDelete(perform: { indexSet in
                    exercise.sets.remove(atOffsets: indexSet)
                })
                .onMove(perform: { indices, newOffset in
                    exercise.sets.move(fromOffsets: indices, toOffset: newOffset)
                })
                if activeState {
                    AddSetButton(exercise: exercise)
                }
            }
            if !currentExerciseWorkoutExercises.isEmpty && active {
                Section("Recents") {
                    ForEach(currentExerciseWorkoutExercises.prefix(5)) { w in
                        RecentsItem(exercise: w)
                    }
                }
            }
        }
        .onAppear {
            activeState = active
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
            if editMode == .active {
                Button {
                    editMode = .inactive
                    activeState = active
                } label: {
                    Text("Done")
                }
            } else {
                Button {
                    showInfoSheet.toggle()
                } label: {
                    Label("Info", systemImage: "info.circle")
                }
                Menu {
                    Button {
                        editMode = .active
                        activeState = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                } label: {
                    Label("More", systemImage: "ellipsis.circle")
                }
                if focusedField != nil {
                    Button {
                        focusedField = nil
                    } label: {
                        Text("Done")
                    }
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Workout.self, configurations: config)
    let exercise = Exercise(name: "Bench Press", type: .weight_reps, primaryMuscleGroup: .chest, secondaryMuscleGroups: [.triceps, .shoulders])
    
    exercise.instructions = ["Lie flat on a bench with feet firmly on the ground.\nGrip the barbell slightly wider than shoulder-width apart.\nUnrack the barbell and hold it straight above your chest with arms fully extended.\nLower the barbell slowly to your mid-chest, keeping elbows at a 45-degree angle.\nPause briefly when the barbell touches your chest.\nPush the barbell back up to the starting position, exhaling as you press.\nLock out your arms at the top and repeat for desired reps.\nRack the barbell safely after completing your set."]
    
    exercise.pinnedNotes = [
        ExerciseNote(text: "Keep your back flat on the bench"),
        ExerciseNote(text: "Don't flare your elbows out"),
        ExerciseNote(text: "Use a spotter for heavy weights")
    ]
    
    exercise.video = "https://www.youtube.com/watch?v=U5zrloYWwxw"
    
    let workout_exercise = WorkoutExercise(exercise: exercise, sets: [
        .init(reps: 8, weight: 60),
        .init(reps: 8, weight: 70),
        .init(reps: 6, weight: 70)
    ])
    workout_exercise.sets[0].type = .warmup
    workout_exercise.sets[1].type = .working
    workout_exercise.sets[2].type = .cooldown
    
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
    
    workout_exercise.workout = Workout(date: Date())
    
    for workout_exercise in workout_exercises {
        workout_exercise.workout = Workout(date: Date())
        container.mainContext.insert(workout_exercise)
    }
    
    return NavigationStack {
        ActiveWorkoutExerciseView(exercise: workout_exercise, active: true)
    }
    .modelContainer(container)
}
