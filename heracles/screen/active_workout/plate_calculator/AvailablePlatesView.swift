//
//  PlatesView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 11/04/2025.
//

import SwiftUI
import SwiftData

struct AvailablePlateView: View {
    @Bindable var plate: Plate
    
    var body: some View {
        HStack {
            Image(systemName: "circle.fill")
                .imageScale(.large)
                .foregroundStyle(plate.color.getAsColor())
            Text("\(plate.weight.formatted()) kg")
            Spacer()
            Stepper {
                
                HStack {
                    Spacer()
                    Group {
                        Text("×")
                            .padding(.trailing, -5)
                        TextField("count", value: $plate.count, format: .number)
                            .keyboardType(.numberPad)
                            .frame(width: 25)
                    }
                    .foregroundStyle(.secondary)
                }
                    
            } onIncrement: {
                plate.count += 1
                
            } onDecrement: {
                plate.count -= 1
            }
        }
    }
}

// TODO: better match visuals with ios
struct PlateColorPicker : View {
    @Binding var color: PlateColor
    
    static let desiredColumns = 6
    
    let rows = (PlateColor.allCases.count + desiredColumns - 1) / desiredColumns
    
    var body: some View {
        Grid {
            ForEach(0..<rows, id: \.self) { row in
                GridRow {
                    ForEach(0..<PlateColorPicker.desiredColumns, id: \.self) { column in
                        let index = row * PlateColorPicker.desiredColumns + column
                        if index < PlateColor.allCases.count {
                            let color = PlateColor.allCases[index]
                            Button {
                                self.color = color
                            } label: {
                                Circle()
                                    .padding(.all, 5)
                                    .foregroundStyle(color.getAsColor())
                                    .overlay {
                                        if self.color == color {
                                            Circle()
                                                .stroke(Color.secondary, lineWidth: 3)
                                                .opacity(0.5)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

}

struct NewPlateView : View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var weight: Double = 20.0
    @State private var color: PlateColor = .red
    @State private var count: Int = 1
    @State private var diameter: Double = 450.0
    @State private var height: Double = 20.0
    @State private var showCancellationWarning = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body : some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        PlatesGraphicsView(plates: [Plate(weight: weight, color: color, width: height, height: diameter, count: 1)], scale: 0.4)
                            .transformEffect(.init(translationX: 100, y: 0)) // TODO: temporary - find a better way to center this
                            .frame(width: 400, height: 200)
                        Spacer()
                    }
                    .frame(width: .infinity)
                        
                        
                    LabeledContent("Weight") {
                        Stepper {
                            HStack {
                                TextField("weight", value: $weight, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                Text("kg")
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
                    LabeledContent("Count") {
                        Stepper {
                                TextField("count", value: $count, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                
                        } onIncrement: {
                            count += 1
                        } onDecrement: {
                            if count > 0 {
                                count -= 1
                            }
                        }
                    }
                }
                Section {
                    PlateColorPicker(color: $color)
                }
                
                
                Section("Dimensions") {
                    LabeledContent("Diameter") {
                        TextField("diameter", value: $diameter, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("mm")
                        
                    }
                    LabeledContent("Height") {
                        TextField("height", value: $height, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("mm")
                        
                    }
                }
                    
            }
            .navigationTitle("New Plate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        modelContext.insert(Plate(weight: weight, color: color, width: height, height: diameter, count: count))
                        dismiss()
                    } label: {
                        Text("Add")
                    }
                    .fontWeight(.bold)
                }
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        // TODO: check if any changes occured
                        showCancellationWarning.toggle()
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

struct AvailablePlatesView: View {
    var plates: [Plate]
    @State private var showNewPlate = false
    
    var body: some View {
        List(plates) { plate in
            AvailablePlateView(plate: plate)
        }
        .navigationTitle("Available Plates")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    showNewPlate.toggle()
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Plate")
                    }
                    .font(.headline)
                    
                    
                }
                Spacer()
            }
        }
        .sheet(isPresented: $showNewPlate) {
            NewPlateView()
        }
    }
}

#Preview {
    NavigationStack {
        AvailablePlatesView(plates: defaultPlates)
    }
    .modelContainer(for: Plate.self, inMemory: true)  { result in
        do {
            let container = try result.get()
            preloadPlates(container)
        } catch {
            print("Failed to create model container.")
        }
    }
}
