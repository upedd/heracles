//
//  ExerciseEditor.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 12/04/2025.
//

import SwiftUI

struct MultiPicker<T: Hashable, Content: View> : View {
    var label: String
    var selectedLabel: String // TODO: improve
    var items: [T]
    @Binding var selectedItems: [T]
    @ViewBuilder var content: (T) -> Content
    
    var body : some View {
        NavigationLink {
            List {
                ForEach(items, id: \.self) { item in
                    HStack {
                        content(item)
                        Spacer()
                        Button {
                            if selectedItems.contains(item) {
                                selectedItems.removeAll { $0 == item }
                            } else {
                                selectedItems.append(item)
                            }
                        } label: {
                            if selectedItems.contains(item) {
                                Image(systemName: "checkmark")
                                    .font(.headline)
                            }
                        }
                    }
                }
            }
            .navigationTitle(label)
        } label: {
            HStack {
                Text(label)
                Spacer()
                Text(selectedLabel).foregroundStyle(.secondary)
            }
        }
    }
}

struct ExerciseEditor: View {
    enum ExerciseType: String, CaseIterable {
        case weightAndReps = "Weight and Reps"
        case distanceAndTime = "Distance and Time"
    }
    
    @Binding var name: String
    @Binding var primaryMuscles: [Muscle]
    @Binding var secondaryMuscles: [Muscle]
    @Binding var equipment: [Equipment]
    @Binding var instructions: [String]
    @Binding var exerciseType: ExerciseType
    @FocusState var instructionFocused: Int?
    
    var primaryMusclesLabel: String {
        if primaryMuscles.isEmpty {
            return "None"
        } else if primaryMuscles.count == 1 {
            return primaryMuscles.first!.displayName()
        } else {
            
            return primaryMuscles.prefix(primaryMuscles.count - 1).map { $0.displayName() }.joined(separator: ", ") + " and " + primaryMuscles.last!.displayName()
        }
    }
    
    var secondaryMusclesLabel: String {
        if secondaryMuscles.isEmpty {
            return "None"
        } else if secondaryMuscles.count == 1 {
            return secondaryMuscles.first!.displayName()
        } else {
            return secondaryMuscles.prefix(secondaryMuscles.count - 1).map { $0.displayName() }.joined(separator: ", ") + " and " + secondaryMuscles.last!.displayName()
        }
    }
    
    var equipmentLabel: String {
        if equipment.isEmpty {
            return "None"
        } else if equipment.count == 1 {
            return equipment.first!.displayName()
        } else {
            return equipment.prefix(equipment.count - 1).map { $0.displayName() }.joined(separator: ", ") + " and " + equipment.last!.displayName()
        }
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                Picker("Type", selection: $exerciseType) {
                    ForEach(ExerciseType.allCases, id: \.self) { type in
                        Text(type.rawValue)
                            .tag(type)
                    }
                }
            }
            Section {
                MultiPicker(label: "Primary Muscles", selectedLabel: primaryMusclesLabel, items: Muscle.allCases, selectedItems: $primaryMuscles) { item in
                    Text(item.displayName())
                }
                MultiPicker(label: "Secondary Muscles", selectedLabel: secondaryMusclesLabel, items: Muscle.allCases, selectedItems: $secondaryMuscles) { item in
                    Text(item.displayName())
                }
                
            }
            Section {
                MultiPicker(label: "Equipment", selectedLabel: equipmentLabel, items: Equipment.allCases, selectedItems: $equipment) { item in
                    Text(item.displayName())
                }
            }
            Section("Instructions") {
                ForEach(0..<instructions.count, id: \.self) { idx in
                    TextField("Step \(idx + 1)", text: $instructions[idx], axis: .vertical)
                        .focused($instructionFocused, equals: idx)
                        .lineLimit(1...10)
                    
                }
                .onDelete { indexSet in
                    instructions.remove(atOffsets: indexSet)
                }
            }
            
        }
        .onChange(of: instructionFocused) { _, newValue in
            
            var offset = 0
            
            instructions = instructions
                .enumerated()
                .filter { index, instruction in
                    if instruction.isEmpty {
                        if newValue != nil && index < newValue ?? 0 {
                            offset -= 1
                        }
                        return false
                    }
                    return true
                }
                .map { index, instruction in
                    instruction
                }
        
                    
            
            //filter {!$0.isEmpty}
            instructions.append("")
            if instructionFocused != nil {
                instructionFocused! += offset
            }
        }
        .onChange(of: instructions) { _, newValue in
            if let last = newValue.last, !last.isEmpty {
                instructions.append("")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ExerciseEditor(name: .constant(""), primaryMuscles: .constant([Muscle.abductors, Muscle.abs, Muscle.biceps]), secondaryMuscles: .constant([]), equipment: .constant([]), instructions: .constant([""]), exerciseType: .constant(ExerciseEditor.ExerciseType.weightAndReps))
    }
}
