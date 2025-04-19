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
            .contextMenu {
                Picker("Set Type", selection: $set.type) {
                    ForEach(SetType.allCases, id: \.rawValue) { type in
                        Text(type.rawValue).tag(type)
                    }
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
    
    class OpenRPENotifer {
        static let openRPEPublisher: PassthroughSubject<Void, Never> = .init()
    }
    
    class OpenStopwatchNotifier {
        static let openStopwatchPublisher: PassthroughSubject<Void, Never> = .init()
    }
    class OpenPlateCalculatorNotifier {
        static let openPlateCalculatorPublisher: PassthroughSubject<Void, Never> = .init()
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
                    OpenPlateCalculatorNotifier.openPlateCalculatorPublisher.send()
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
                    OpenRPENotifer.openRPEPublisher.send()
                    playSystemFeedback?()
                } label: {
                    Text("RPE")
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
                    OpenStopwatchNotifier.openStopwatchPublisher.send()
                } label: {
                    Label("stopwatch", systemImage: "stopwatch")
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
    @ObservedObject var stopwatchTimerManager: TimerManager
    var isInTemplate: Bool // temp
    
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
            set.reps != nil ? "\(set.reps!)" : "0"
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
    
    @State private var showRPEPicker = false
    @State private var showStopwatch = false
    @State private var showPlateCalculator = false
    var body: some View {
        HStack(alignment: .center) {
            WorkoutExerciseSetIndex(set: set, idx: idx, active: active)
            Group {
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
                            .onReceive(CustomKeyboard.OpenPlateCalculatorNotifier.openPlateCalculatorPublisher) {
                                if focusedField == WorkoutExerciseFocusState(setIdx: rawIdx, fieldIdx: .weight) {
                                    print("show me!")
                                    showPlateCalculator = true
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
                                .onReceive(CustomKeyboard.OpenStopwatchNotifier.openStopwatchPublisher) {
                                    if focusedField == WorkoutExerciseFocusState(setIdx: rawIdx, fieldIdx: .minutes) {
                                        showStopwatch = true
                                        stopwatchTimerManager.reset()
                                        stopwatchTimerManager.elapsedTime = set.time ?? 0
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
                                .onReceive(CustomKeyboard.OpenStopwatchNotifier.openStopwatchPublisher) {
                                    if focusedField == WorkoutExerciseFocusState(setIdx: rawIdx, fieldIdx: .seconds) {
                                        showStopwatch = true
                                        stopwatchTimerManager.reset()
                                        stopwatchTimerManager.elapsedTime = set.time ?? 0
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
                            .onReceive(CustomKeyboard.OpenRPENotifer.openRPEPublisher) {
                                if focusedField == WorkoutExerciseFocusState(setIdx: rawIdx, fieldIdx: .reps) {
                                    showRPEPicker = true
                                    set.RPE = 8.5
                                }
                            }
                    }
                    if set.RPE != nil {
                        Text("RPE")
                        Button {
                            showRPEPicker = true
                        } label: {
                            Text(rpe_to_display[set.RPE!]!)
                                .foregroundStyle(Color.primary)
                        }
                        .padding(.horizontal, 5)
                        .padding(.vertical, 3)
                        .background(Material.regular)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .buttonStyle(.borderless)
                    }
                
                
            }
            .opacity(active && set.completed ? 0.5 : 1)
        }
        .sheet(isPresented: $showRPEPicker) {
            NavigationStack {
                VStack(alignment: .center) {
                    Picker("RPE", selection: $set.RPE) {
                        Text("10").tag(10.0)
                        Text("9.5").tag(9.5)
                        Text("9").tag(9.0)
                        Text("8.5").tag(8.5)
                        Text("8").tag(8.0)
                        Text("7.5").tag(7.5)
                        Text("7").tag(7.0)
                        Text("6.5").tag(6.5)
                    }
                    .pickerStyle(.wheel)
                    if set.RPE != nil {
                        Text(rpe_to_descriptions[set.RPE!]!.0)
                            .font(.title3.bold())
                            .padding(.bottom, 5)
                        Text(rpe_to_descriptions[set.RPE!]!.1)
                            .multilineTextAlignment(.center)
                            .font(.body)
                    }
                }
                .padding()
                .navigationTitle("Chosen RPE")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showRPEPicker = false
                            set.RPE = nil
                        } label: {
                            Text("Clear")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showRPEPicker = false
                        } label: {
                            Label("Close", systemImage: "xmark")
                                .imageScale(.medium)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.secondary)
                        }
                        .padding(.all, 8)
                        .buttonStyle(.borderless)
                        .background(Material.regular)
                        .labelStyle(.iconOnly)
                        .clipShape(Circle())
                    }
                }
                .toolbarTitleDisplayMode(.inline)
                .presentationDetents([.fraction(0.55)])
                
            }
            
        }
        
        .sheet(isPresented: $showStopwatch, onDismiss: {
            stopwatchTimerManager.pause()
        }) {
            NavigationStack {
                VStack {
                    if stopwatchTimerManager.isRunning {
                        Text(TimeDataSource<Date>.currentDate, format: .stopwatch(startingAt: .now.addingTimeInterval(-stopwatchTimerManager.elapsedTime)))
                            .font(.system(size: 90, weight: .thin))
                            .padding(.top, 10)
                    } else {
                        Text(Date.now, format: .stopwatch(startingAt: .now.addingTimeInterval(-stopwatchTimerManager.elapsedTime)))
                            .font(.system(size: 90, weight: .thin))
                            .padding(.top, 10)
                        
                    }
                    HStack {
                        Button("Reset") {
                            stopwatchTimerManager.reset()
                        }
                        .frame(width: 90, height: 90)
                        .foregroundStyle(Color.primary)
                        .background(Material.regular)
                        .clipShape(Circle())
                        
                        Spacer()
                        Button {
                            if stopwatchTimerManager.isRunning {
                                stopwatchTimerManager.pause()
                            } else {
                                stopwatchTimerManager.start()
                            }
                            
                        } label: {
                            ZStack {
                                Color(uiColor: .systemBackground)
                                    .frame(width: 90, height: 90)
                                Text(stopwatchTimerManager.isRunning ? "Pause" : "Start")
                                
                                    .foregroundStyle(Color.primary)
                                    .frame(width: 90, height: 90)
                                    .background(Material.regular)
                                
                                if stopwatchTimerManager.isRunning {
                                    Color.red.blendMode(.multiply)
                                        .frame(width: 90, height: 90)
                                    
                                } else {
                                    Color.green.blendMode(.multiply)
                                        .frame(width: 90, height: 90)
                                }
                            }
                            .transaction { transaction in
                                transaction.animation = nil
                            }
                            .clipShape(Circle())
                            
                            
                        }
                        
                        
                        
                    }
                }
                .padding()
                .navigationTitle("Stopwatch")
                .toolbar {
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            stopwatchTimerManager.pause()
                            showStopwatch = false
                        } label: {
                            Label("Close", systemImage: "xmark")
                                .imageScale(.medium)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.secondary)
                        }
                        .padding(.all, 8)
                        .buttonStyle(.borderless)
                        .background(Material.regular)
                        .labelStyle(.iconOnly)
                        .clipShape(Circle())
                    }
                }
                .toolbarTitleDisplayMode(.inline)
                .presentationDetents([.fraction(0.55)])
            }
        }
        
        .padding(.vertical, 2)
        .font(.system(.body, design: .rounded, weight: .medium))
        .alignmentGuide(.listRowSeparatorLeading) { _ in
            40
        }
        .sheet(isPresented: $showPlateCalculator) {
            NavigationStack {
                // TODO: bugs
                // TODO: negative values in weight and count
                // TODO: display weight for side maybe? just more information
                // TODO: more colors
                
                PlateCalculator(weight: set.weight!)
            }
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
        var active: Bool
        
        
        var body: some View {
            Button {
                let sortedSets = exercise.sets.sorted(by: {$0.order < $1.order})
                if let last = sortedSets.last {
                    exercise.sets.append(.init(order: exercise.sets.count, reps: last.reps, weight: last.weight, time: last.time, distance: last.distance))
                } else {
                    exercise.sets.append(.init(order: exercise.sets.count))
                }
                
                if !active {
                    sortedSets.last?.completed = true
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
                    ForEach(exercise.sets.sorted(by: {$0.order < $1.order})) { set in
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
        return sortedSets.map { set in
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
            $0.exercise == exercise.exercise && $0.workout != nil && $0.workout! != exercise.workout! && !$0.workout!.active
        }
    }
    
    var active: Bool
    var isInTemplate: Bool = false // temp!
    
    @State var showInfoSheet = false
    @State var activeState: Bool = false
    
    @FocusState var focusedField: WorkoutExerciseFocusState?
    @ObservedObject var stopwatchTimerManager = TimerManager.make(id: "stopwatch")
    
    var sortedSets: [WorkoutSet] {
        exercise.sets.sorted { $0.order < $1.order }
    }
    
    @State private var showDeleteAlert = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
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
                    WorkoutExerciseSetView(set: element.0, exercise: exercise, idx: element.1, active: activeState, rawIdx: rawIdx, focusedField: $focusedField, stopwatchTimerManager: stopwatchTimerManager, isInTemplate: isInTemplate)
                    
                }
                .onDelete(perform: { indexSet in
                    var updateSets = sortedSets
                    
                    updateSets.remove(atOffsets: indexSet)
                    for (idx, set) in updateSets.enumerated() {
                        set.order = idx
                    }
                    exercise.sets = updateSets
                })
                .onMove(perform: { indices, newOffset in
                    var updateSets = sortedSets
                    updateSets.move(fromOffsets: indices, toOffset: newOffset)
                    for (idx, set) in updateSets.enumerated() {
                        set.order = idx
                    }
                })
                AddSetButton(exercise: exercise, active: active)
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
        .onChange(of: stopwatchTimerManager.elapsedTime) {
            if let focusedField {
                sortedSets[focusedField.setIdx].time = stopwatchTimerManager.elapsedTime
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
        .alert("Delete exercise \"\(exercise.exercise.name)\" from \(exercise.workout != nil ? "workout" : "template")?", isPresented:$showDeleteAlert, actions: {
            Button("Delete", role: .destructive) {
                if let workout = exercise.workout {
                    workout.exercises.removeAll(where: { $0 == exercise })
                }
                if let template = exercise.template {
                    template.exercises.removeAll(where: { $0 == exercise })
                }
                modelContext.delete(exercise)
                presentationMode.wrappedValue.dismiss()
            }
        }, message: {
            if exercise.sets.count > 0 {
                Text("This will delete all sets from this exercise.")
            }
        })
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
                    Button(role: .destructive) {
                        showDeleteAlert.toggle()
                    } label: {
                        Label(exercise.workout != nil ? "Delete from Workout" : "Delete from Template", systemImage: "trash")
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
    let config = ModelConfiguration(for: Workout.self, Barbell.self, Plate.self, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Workout.self, Barbell.self, Plate.self, configurations: config)
    
    preloadPlates(container)
    preloadBarbells(container)
    let exercise = Exercise(name: "Bench Press", type: .weight_reps, primaryMuscleGroup: .chest, secondaryMuscleGroups: [.triceps, .shoulders])
    
    exercise.instructions = ["Lie flat on a bench with feet firmly on the ground.\nGrip the barbell slightly wider than shoulder-width apart.\nUnrack the barbell and hold it straight above your chest with arms fully extended.\nLower the barbell slowly to your mid-chest, keeping elbows at a 45-degree angle.\nPause briefly when the barbell touches your chest.\nPush the barbell back up to the starting position, exhaling as you press.\nLock out your arms at the top and repeat for desired reps.\nRack the barbell safely after completing your set."]
    
    exercise.pinnedNotes = [
        ExerciseNote(text: "Keep your back flat on the bench"),
        ExerciseNote(text: "Don't flare your elbows out"),
        ExerciseNote(text: "Use a spotter for heavy weights")
    ]
    exercise.trackWeight = true
    exercise.trackTime = false
    exercise.trackDuration = false
    exercise.trackReps = true
    
    exercise.video = "https://www.youtube.com/watch?v=U5zrloYWwxw"
    
    let workout_exercise = WorkoutExercise(exercise: exercise, order: 0, sets: [
        .init(order: 0, reps: 8, weight: 60),
        .init(order: 1, reps: 8, weight: 70),
        .init(order: 2, reps: 6, weight: 70)
    ])
    workout_exercise.sets[0].type = .warmup
    workout_exercise.sets[1].type = .working
    workout_exercise.sets[2].type = .cooldown
    
    let workout_exercises: [WorkoutExercise] = [
        .init(exercise: exercise, order: 0, sets: [
            .init(order: 0, reps: 8, weight: 60),
            .init(order: 1, reps: 8, weight: 70),
            .init(order: 2, reps: 6, weight: 70)
        ]),
        .init(exercise: exercise, order: 1, sets: [
            .init(order: 0, reps: 8, weight: 60),
            .init(order: 1, reps: 8, weight: 70),
            .init(order: 2, reps: 6, weight: 70)
        ]),
        .init(exercise: exercise, order: 2, sets: [
            .init(order: 0, reps: 8, weight: 60),
            .init(order: 1, reps: 8, weight: 70),
            .init(order: 2, reps: 6, weight: 70)
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
