//
//  ActiveWorkoutExerciseView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 19/02/2025.
//

import SwiftUI
import CustomKeyboardKit
import SwiftData
import Combine

// TODO: cleanup (absolute horrors below!)
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

// TODO: failed sets?
// TODO: better context menu
struct WorkoutExerciseSetIndex : View {
    @Bindable var set: WorkoutSet
    var idx: Int
    var active: Bool
    var body : some View {
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
    }
}

struct WorkoutExerciseSetInput : View {
    @Bindable var set: WorkoutSet
    var label: String
    var targetFocusState: WorkoutExerciseFocusState
    var text: Binding<String>
    @Binding var selection: TextSelection?
    @FocusState.Binding var focusedField: WorkoutExerciseFocusState?
    
    
    var body : some View {
        TextField(label, text: text, selection: $selection)
            .frame(width: 50)
            .padding(.horizontal, 5)
            .padding(.vertical, 3)
            .multilineTextAlignment(.center)
            .background(Material.regular)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .focused($focusedField, equals: targetFocusState)
        
            .onChange(of: focusedField) {
                if focusedField == targetFocusState {
                    selection = .init(range: text.wrappedValue.startIndex..<text.wrappedValue.endIndex)
                }
            }
    }
}

struct TextKeyboardButton : View {
    var text: String
    var textDocumentProxy: UITextDocumentProxy
    var playSystemFeedback: (() -> Void)?
    
    var body : some View {
        Button(text) {
            textDocumentProxy.insertText(text)
            playSystemFeedback?()
        }
    }
}

extension CustomKeyboard {
    class IncOrDecNotifier {
        static let incOrDecPublisher: PassthroughSubject<Int, Never> = .init()
    }
    
    static let distanceKeyboard = CustomKeyboardBuilder { textDocumentProxy, onSubmit, playSystemFeedback in
        VStack {
            HStack {
                TextKeyboardButton(text: "1", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                TextKeyboardButton(text: "2", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                TextKeyboardButton(text: "3", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                // TODO
                Button {
                    playSystemFeedback?()
                } label: {
                    Label("dumbbell", systemImage: "dumbbell")
                }
                .labelStyle(.iconOnly)
                .buttonStyle(KeyboardButtonStyle(secondary: true))
                .opacity(0)
                .disabled(true)
                .accessibilityHidden(true)
            }
            HStack {
                TextKeyboardButton(text: "4", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                TextKeyboardButton(text: "5", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                TextKeyboardButton(text: "6", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                Button {
                    IncOrDecNotifier.incOrDecPublisher.send(-1)
                    playSystemFeedback?()
                } label: {
                    Label("minus", systemImage: "minus")
                }
                .labelStyle(.iconOnly)
                .buttonStyle(KeyboardButtonStyle(secondary: true))
            }
            HStack {
                TextKeyboardButton(text: "7", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                TextKeyboardButton(text: "8", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                TextKeyboardButton(text: "9", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                Button {
                    IncOrDecNotifier.incOrDecPublisher.send(1)
                    playSystemFeedback?()
                } label: {
                    Label("plus", systemImage: "plus")
                }
                .labelStyle(.iconOnly)
                .buttonStyle(KeyboardButtonStyle(secondary: true))
            }
            HStack {
                TextKeyboardButton(text: ".", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                    .buttonStyle(BorderlessKeyboardButtonStyle())
                TextKeyboardButton(text: "0", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
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
    
    static let weightKeyboard = CustomKeyboardBuilder { textDocumentProxy, onSubmit, playSystemFeedback in
        VStack {
            HStack {
                TextKeyboardButton(text: "1", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                TextKeyboardButton(text: "2", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                TextKeyboardButton(text: "3", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                // TODO: icon
                // TODO: add weight calculator
                // TODO: rpe!
                Button {
                    playSystemFeedback?()
                } label: {
                    Label("dumbbell", systemImage: "dumbbell")
                }
                .labelStyle(.iconOnly)
                .buttonStyle(KeyboardButtonStyle(secondary: true))
                
            }
            HStack {
                TextKeyboardButton(text: "4", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                TextKeyboardButton(text: "5", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                TextKeyboardButton(text: "6", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                Button {
                    IncOrDecNotifier.incOrDecPublisher.send(-1)
                    playSystemFeedback?()
                } label: {
                    Label("minus", systemImage: "minus")
                }
                .labelStyle(.iconOnly)
                .buttonStyle(KeyboardButtonStyle(secondary: true))
            }
            HStack {
                TextKeyboardButton(text: "7", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                TextKeyboardButton(text: "8", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                TextKeyboardButton(text: "9", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                Button {
                    IncOrDecNotifier.incOrDecPublisher.send(1)
                    playSystemFeedback?()
                } label: {
                    Label("plus", systemImage: "plus")
                }
                .labelStyle(.iconOnly)
                .buttonStyle(KeyboardButtonStyle(secondary: true))
            }
            HStack {
                TextKeyboardButton(text: ".", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                    .buttonStyle(BorderlessKeyboardButtonStyle())
                TextKeyboardButton(text: "0", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
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
    
    static let repsKeyboard = CustomKeyboardBuilder { textDocumentProxy, onSubmit, playSystemFeedback in
        VStack {
            HStack {
                TextKeyboardButton(text: "1", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                TextKeyboardButton(text: "2", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                TextKeyboardButton(text: "3", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                // TODO: icon
                // TODO: add weight calculator
                // TODO: rpe!
                Button {
                    playSystemFeedback?()
                } label: {
                    Label("dumbbell", systemImage: "dumbbell")
                }
                .labelStyle(.iconOnly)
                .buttonStyle(KeyboardButtonStyle(secondary: true))
                
            }
            HStack {
                TextKeyboardButton(text: "4", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                TextKeyboardButton(text: "5", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                TextKeyboardButton(text: "6", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                Button {
                    IncOrDecNotifier.incOrDecPublisher.send(-1)
                    playSystemFeedback?()
                } label: {
                    Label("minus", systemImage: "minus")
                }
                .labelStyle(.iconOnly)
                .buttonStyle(KeyboardButtonStyle(secondary: true))
            }
            HStack {
                TextKeyboardButton(text: "7", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                TextKeyboardButton(text: "8", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                TextKeyboardButton(text: "9", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                Button {
                    IncOrDecNotifier.incOrDecPublisher.send(1)
                    playSystemFeedback?()
                } label: {
                    Label("plus", systemImage: "plus")
                }
                .labelStyle(.iconOnly)
                .buttonStyle(KeyboardButtonStyle(secondary: true))
            }
            HStack {
                // TODO: find a way to not have this button without breaking layout
                TextKeyboardButton(text: ".", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                    .buttonStyle(BorderlessKeyboardButtonStyle())
                    .disabled(true)
                    .opacity(0)
                    .accessibilityHidden(true)
                TextKeyboardButton(text: "0", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
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
    
    static let timeKeyboard = CustomKeyboardBuilder { textDocumentProxy, onSubmit, playSystemFeedback in
        VStack {
            HStack {
                TextKeyboardButton(text: "1", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                TextKeyboardButton(text: "2", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                TextKeyboardButton(text: "3", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                // TODO: icon
                // TODO: add weight calculator
                // TODO: rpe!
                Button {
                    playSystemFeedback?()
                } label: {
                    Label("timer", systemImage: "timer")
                }
                .labelStyle(.iconOnly)
                .buttonStyle(KeyboardButtonStyle(secondary: true))
                
            }
            HStack {
                TextKeyboardButton(text: "4", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                TextKeyboardButton(text: "5", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                TextKeyboardButton(text: "6", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                Button {
                    IncOrDecNotifier.incOrDecPublisher.send(-1)
                    playSystemFeedback?()
                } label: {
                    Label("minus", systemImage: "minus")
                }
                .labelStyle(.iconOnly)
                .buttonStyle(KeyboardButtonStyle(secondary: true))
            }
            HStack {
                TextKeyboardButton(text: "7", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                TextKeyboardButton(text: "8", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                TextKeyboardButton(text: "9", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                Button {
                    IncOrDecNotifier.incOrDecPublisher.send(1)
                    playSystemFeedback?()
                } label: {
                    Label("plus", systemImage: "plus")
                }
                .labelStyle(.iconOnly)
                .buttonStyle(KeyboardButtonStyle(secondary: true))
            }
            HStack {
                // TODO: find a way to not have this button without breaking layout
                TextKeyboardButton(text: ".", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
                    .buttonStyle(BorderlessKeyboardButtonStyle())
                    .disabled(true)
                    .opacity(0)
                    .accessibilityHidden(true)
                TextKeyboardButton(text: "0", textDocumentProxy: textDocumentProxy, playSystemFeedback: playSystemFeedback)
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
}

extension String {
    func paddingLeading(toLength: Int, withPad: String, startingAt: Int) -> String {
        return String(String(self.reversed()).padding(toLength: toLength, withPad: withPad, startingAt: startingAt).reversed())
    }
}

struct WorkoutExerciseSetView : View  {
    @Bindable var set: WorkoutSet
    @Bindable var exercise: WorkoutExercise
    var idx: Int
    var active: Bool
    // MESS!!!
    var rawIdx: Int
    @FocusState.Binding var focusedField: WorkoutExerciseFocusState?
    
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
                    return WorkoutExerciseSetView.formatter.string(from: NSNumber(value: weight)) ?? "0"
                }
            } else {
                return "0"
            }
        } set: { newValue in
            if exercise.exercise.trackWeight {
                set.weight = Double(newValue) ?? 0
            }
        }
    }
    
    @State private var weightTextSelection: TextSelection?
    
    private var distanceText: Binding<String> {
        Binding {
            if let distance = set.distance {
                if distance == 0 {
                    return "0"
                } else {
                    return WorkoutExerciseSetView.formatter.string(from: NSNumber(value: distance)) ?? "0"
                }
            } else {
                return "0"
            }
        } set: { newValue in
            if exercise.exercise.trackDuration {
                set.distance = Double(newValue) ?? 0
            }

        }
    }
    
    @State private var distanceTextSelection: TextSelection?
    
    private var repsText: Binding<String> {
        Binding {
            set.reps != nil ? "\(set.reps!)" : ""
        } set: { newValue in
            if exercise.exercise.trackReps {
                set.reps = Int(newValue) ?? 0
            }
        }
    }
    
    // TODO: improve ux of duration field on longer inputs
    
    private var minutesText: Binding<String> {
        Binding {
            let minutes = Int(set.time ?? 0) / 60
            let paddedString = "\(String(minutes).paddingLeading(toLength: 2, withPad: "0", startingAt: 0))"
            return paddedString
        } set: {newValue in
            if exercise.exercise.trackTime {
                if let time = set.time {
                    let timeWithoutMinutes = Int(time) % 60
                    let minutes = Int(newValue) ?? 0
                    set.time = TimeInterval((minutes * 60) + timeWithoutMinutes)
                } else {
                    set.time = TimeInterval((Int(newValue) ?? 0) * 60)
                }
            }
        }
    }
    
    @State private var minutesTextSelection: TextSelection?
    
    private var secondsText: Binding<String> {
        Binding {
            if let time = set.time {
                let seconds = Int(time) % 60
                let paddedString = "\(String(seconds).paddingLeading(toLength: 2, withPad: "0", startingAt: 0))"
                return paddedString
            } else {
                return "00"
            }
        } set: {newValue in
            if exercise.exercise.trackTime {
                if let time = set.time {
                    let timeWithoutSeconds = (Int(time) / 60) * 60
                    let seconds = (Int(newValue) ?? 0) % 60
                    set.time = TimeInterval(timeWithoutSeconds + seconds)
                } else {
                    set.time = TimeInterval((Int(newValue) ?? 0) % 60)
                }
            }
        }
    }
    @State private var secondsTextSelection: TextSelection?
    
    @State private var repsTextSelection: TextSelection?
    
    func onSubmit() {
        let focusedFieldIdx = exercise.exercise.fields.firstIndex(where: { $0 == focusedField?.fieldIdx })
        if let focusedFieldIdx {
            if focusedFieldIdx + 1 < exercise.exercise.fields.count {
                focusedField = WorkoutExerciseFocusState(setIdx: rawIdx, fieldIdx: exercise.exercise.fields[focusedFieldIdx + 1])
            } else {
                set.completed = true
                if rawIdx == exercise.sets.count - 1 {
                    focusedField = nil
                } else {
                    focusedField = WorkoutExerciseFocusState(setIdx: rawIdx + 1, fieldIdx: exercise.exercise.fields[0])
                }
            }
        } else {
            focusedField = nil
        }
        
    }
    
    var body: some View {
        HStack(alignment: .center) {
            WorkoutExerciseSetIndex(set: set, idx: idx, active: active)
            Group {
                if active {
                    if exercise.exercise.trackTime {
                        WorkoutExerciseSetInput(set: set, label: "distance", targetFocusState: WorkoutExerciseFocusState(setIdx: rawIdx, fieldIdx: .distance), text: distanceText, selection: $distanceTextSelection, focusedField: $focusedField)
                            .customKeyboard(.distanceKeyboard)
                            .onCustomSubmit {
                                onSubmit()
                            }
                            .onReceive(CustomKeyboard.IncOrDecNotifier.incOrDecPublisher) { delta in
                                if focusedField == WorkoutExerciseFocusState(setIdx: rawIdx, fieldIdx: .distance) {
                                    let doubleValue = Double(distanceText.wrappedValue) ?? 0
                                    distanceTextSelection = nil
                                    distanceText.wrappedValue = WorkoutExerciseSetView.formatter.string(from: NSNumber(value: roundToNearestMultiple(of: 0.1, value: doubleValue + 0.1 * Double(delta)))) ?? "0"
                                    distanceTextSelection = .init(range: distanceText.wrappedValue.startIndex..<distanceText.wrappedValue.endIndex)
                                }
                            }
                        Text("km")
                    }
                    
                    if exercise.exercise.trackWeight {
                        WorkoutExerciseSetInput(set: set, label: "weight", targetFocusState: WorkoutExerciseFocusState(setIdx: rawIdx, fieldIdx: .weight), text: weightText, selection: $weightTextSelection, focusedField: $focusedField)
                            .customKeyboard(.weightKeyboard)
                            .onCustomSubmit {
                                onSubmit()
                            }
                            .onReceive(CustomKeyboard.IncOrDecNotifier.incOrDecPublisher) { delta in
                                if focusedField == WorkoutExerciseFocusState(setIdx: rawIdx, fieldIdx: .weight) {
                                    let doubleValue = Double(weightText.wrappedValue) ?? 0
                                    weightTextSelection = nil
                                    weightText.wrappedValue = WorkoutExerciseSetView.formatter.string(from: NSNumber(value: roundToNearestMultiple(of: 1.25, value: doubleValue + 1.25 * Double(delta)))) ?? "0"
                                    weightTextSelection = .init(range: weightText.wrappedValue.startIndex..<weightText.wrappedValue.endIndex)
                                }
                            }
                        Text("kg")
                    }
                    
                    if exercise.exercise.trackDuration {
                        HStack(alignment: .center) {
                            TextField("m", text: minutesText, selection: $minutesTextSelection)
                                .padding(.trailing, -8)
                                .focused($focusedField, equals: WorkoutExerciseFocusState(setIdx: rawIdx, fieldIdx: .minutes))
                            
                                .onChange(of: focusedField) {
                                    if focusedField == WorkoutExerciseFocusState(setIdx: rawIdx, fieldIdx: .minutes) {
                                        minutesTextSelection = .init(range: minutesText.wrappedValue.startIndex..<minutesText.wrappedValue.endIndex)
                                    }
                                }
                                .customKeyboard(.timeKeyboard)
                                .onCustomSubmit {
                                    onSubmit()
                                }
                                .onReceive(CustomKeyboard.IncOrDecNotifier.incOrDecPublisher) { delta in
                                    if focusedField == WorkoutExerciseFocusState(setIdx: rawIdx, fieldIdx: .minutes) {
                                        minutesTextSelection = nil
                                        minutesText.wrappedValue = "\((Int(minutesText.wrappedValue) ?? 0) + delta)"
                                        minutesTextSelection = .init(range: minutesText.wrappedValue.startIndex..<minutesText.wrappedValue.endIndex)
                                    }
                                }

                            Spacer()
                            Text(":")
                            Spacer()
                            TextField("s", text: secondsText, selection: $secondsTextSelection)
                                .padding(.leading, -8)
                                .focused($focusedField, equals: WorkoutExerciseFocusState(setIdx: rawIdx, fieldIdx: .seconds))
                            
                                .onChange(of: focusedField) {
                                    if focusedField == WorkoutExerciseFocusState(setIdx: rawIdx, fieldIdx: .seconds) {
                                        secondsTextSelection = .init(range: secondsText.wrappedValue.startIndex..<secondsText.wrappedValue.endIndex)
                                    }
                                }
                                .customKeyboard(.timeKeyboard)
                                .onCustomSubmit {
                                    onSubmit()
                                }
                                .onReceive(CustomKeyboard.IncOrDecNotifier.incOrDecPublisher) { delta in
                                    if focusedField == WorkoutExerciseFocusState(setIdx: rawIdx, fieldIdx: .seconds) {
                                        secondsTextSelection = nil
                                        secondsText.wrappedValue = "\((Int(secondsText.wrappedValue) ?? 0) + delta)"
                                        secondsTextSelection = .init(range: secondsText.wrappedValue.startIndex..<secondsText.wrappedValue.endIndex)
                                    }
                                }
                        }
                        
                        .frame(width: 50)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 3)
                        .background(Material.regular)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                            
                    }
                    if exercise.exercise.trackReps {
                        Text("×")
                        WorkoutExerciseSetInput(set: set, label: "reps", targetFocusState: WorkoutExerciseFocusState(setIdx: rawIdx, fieldIdx: .reps), text: repsText, selection: $repsTextSelection, focusedField: $focusedField)
                            .customKeyboard(.repsKeyboard)
                            .onCustomSubmit {
                                onSubmit()
                            }
                            .onReceive(CustomKeyboard.IncOrDecNotifier.incOrDecPublisher) { delta in
                                if focusedField == WorkoutExerciseFocusState(setIdx: rawIdx, fieldIdx: .reps) {
                                    let value = Int(repsText.wrappedValue) ?? 0
                                    repsTextSelection = nil
                                    repsText.wrappedValue = "\(value + 1 * delta)"
                                    repsTextSelection = .init(range: repsText.wrappedValue.startIndex..<repsText.wrappedValue.endIndex)
                                }
                            }
                        Text("reps")
                    }
                } else {
                    Text(set.formatted)
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

enum WorkoutExerciseSetField: Hashable {
    case weight
    case distance
    case minutes
    case seconds
    case reps
}

struct WorkoutExerciseFocusState : Hashable, Equatable {
    var setIdx: Int
    var fieldIdx: WorkoutExerciseSetField
}

struct WorkoutExerciseView: View {
    struct AddSetButton : View {
        
        @Bindable var exercise: WorkoutExercise
        
        var body: some View {
            Button {
                if let last = exercise.sets.last {
                    exercise.sets.append(.init(reps: last.reps, weight: last.weight, time: last.time, distance: last.distance))
                } else {
                    exercise.sets.append(.init())
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
                        Text(set.formatted)
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
    
    @FocusState var focusedField: WorkoutExerciseFocusState?
    
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
                    WorkoutExerciseSetView(set: element.0, exercise: exercise, idx: element.1, active: activeState, rawIdx: rawIdx, focusedField: $focusedField)
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
    exercise.trackWeight = false
    exercise.trackTime = true
    exercise.trackDuration = true
    exercise.trackReps = false
    
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
        WorkoutExerciseView(exercise: workout_exercise, active: true)
    }
    .modelContainer(container)
}
