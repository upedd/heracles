//
//  BarbellsView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 10/04/2025.
//

import SwiftUI
import SwiftData

struct BarbellView: View {
    @Bindable var barbell: Barbell
    @Binding var selectedBarbell: Barbell?
    @Environment(Settings.self) private var settings
    
    var body : some View {
        HStack {
            Text(barbell.label)
            Spacer()
            Text("\(barbell.weight.formatted()) \(settings.weightUnit.short())")
                .foregroundStyle(.secondary)
            if selectedBarbell != nil {
                Button {
                    selectedBarbell = barbell
                } label: {
                    if selectedBarbell == barbell {
                        Image(systemName: "checkmark")
                            .font(.headline)
                    }
                }
            }
        }
    }
}

struct NewBarbellView : View {
    @Environment(\.modelContext) private var modelContext
    @State private var label: String = ""
    @State private var weight: Double = 20.0
    
    @State private var showCancellationWarning = false
    @Environment(\.dismiss) private var dismiss
    @Environment(Settings.self) private var settings
    
    var body : some View {
        NavigationStack {
            Form {
                TextField("Label", text: $label)
                LabeledContent("Weight") {
                    Stepper {
                        HStack {
                            TextField("weight", value: $weight, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                            Text("\(settings.weightUnit.short())")
                                .foregroundStyle(.secondary)
                        }
                    } onIncrement: {
                        weight += 1
                    } onDecrement: {
                        if weight > 0 {
                            weight -= 1
                        }
                    }
                    
                }
                    
            }
            .navigationTitle("New Barbell")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        modelContext.insert(Barbell(weight: weight, label: label))
                        dismiss()
                    } label: {
                        Text("Add")
                    }
                    .fontWeight(.bold)
                    .disabled(label.isEmpty || weight < 0)
                }
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        if !label.isEmpty || weight != 20.0 {
                            showCancellationWarning.toggle()
                        } else {
                            dismiss()
                        }
                    } label: {
                        Text("Cancel")
                    }
                }
            }
            .confirmationDialog("Discard Changes?", isPresented: $showCancellationWarning, titleVisibility: .hidden) {
                Button("Discard Changes", role: .destructive) {
                    dismiss()
                }
            }
                
        }
    }
}


struct BarbellsView : View {
    var barbells: [Barbell]
    @Binding var selectedBarbell: Barbell?
    @Environment(\.modelContext) private var modelContext
    
    var listContents: [Barbell] {
        barbells.sorted(by: {$0.weight > $1.weight})
    }
    @State private var showNewBarbellView = false
    
    var body : some View {
        List {
            ForEach(listContents) { barbell in
                BarbellView(barbell: barbell, selectedBarbell: $selectedBarbell)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let barbell = barbells[index]
                    modelContext.delete(barbell)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    showNewBarbellView.toggle()
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Barbell")
                    }
                    .font(.headline)
                    
                    
                }
                Spacer()
            }
        }
        .sheet(isPresented: $showNewBarbellView) {
            NewBarbellView()
        }
        .navigationTitle("Barbells")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        BarbellsView(barbells: defaultBarbells, selectedBarbell: .constant(defaultBarbells[0]))
    }
    .modelContainer(for: Barbell.self, inMemory: true) { result in
        do {
            let container = try result.get()
            preloadBarbells(container)
        } catch {
            print("Failed to create model container.")
        }
    }
    .environment(Settings())
    
}
