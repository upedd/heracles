//
//  PlateCalculator.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 10/04/2025.
//

import SwiftUI
import SwiftData

// TODO: barbell collars
// TODO: show barbell icon in plates view

struct PlatesGraphicsView : View {
    var plates: [Plate]
    var scale = 0.6
    var body: some View {
        Canvas { context, size in
            let gripWidth: CGFloat = 110 * scale
            let gripHeight: CGFloat = 28 * scale
            let flangeWidth: CGFloat = 30 * scale
            let FlangeHeight: CGFloat = 100 * scale
            let sleeveWidth: CGFloat = 415 * scale
            let sleeveHeight: CGFloat = 50 * scale
            
            let grip = CGRect(origin: .init(x: 0, y: (size.height - gripHeight) / 2), size: .init(width: gripWidth, height: gripHeight))
            
            context.fill(Rectangle().path(in: grip), with: .tiledImage(Image("dark_metal_background"), sourceRect: .init(x:0, y:0.1, width: 1, height: 1),  scale: 0.01))
            let flange = CGRect(origin: .init(x: gripWidth, y: (size.height - FlangeHeight) / 2), size: .init(width: flangeWidth, height: FlangeHeight))
            context.fill(Rectangle().path(in: flange), with: .tiledImage(Image("silver_metal_background_1"), sourceRect: .init(x:0, y:0.2, width: 1, height: 1),  scale: 0.02))
            
            
            var currentX = gripWidth + flangeWidth
            for plate in plates {
                for _ in 0..<plate.count {
                    
                    let plateRect = CGRect(origin: .init(x: currentX, y: (size.height - plate.height * scale) / 2), size: .init(width: plate.width * scale, height: plate.height * scale))
                    context.fill(RoundedRectangle(cornerRadius: 2).path(in: plateRect), with: .style(plate.color.getAsColor().gradient))
                    currentX += plate.width * scale + 0.5
                }
            }
            let sleeve = CGRect(origin: .init(x: currentX, y: (size.height - sleeveHeight) / 2), size: .init(width: sleeveWidth - currentX + gripWidth + flangeWidth, height: sleeveHeight))
            context.fill(Rectangle().path(in: sleeve), with: .tiledImage(Image("silver_metal_background_1"), sourceRect: .init(x:0, y:0.1, width: 1, height: 1),  scale: 0.01))
        }
    }
}

struct PlatesView: View {
    var targetWeight: Double
    var realWeight: Double
    var candidate: Candidate
    
    var plates: [Plate] {
        candidate.combination
            .sorted {
                $0.weight > $1.weight
            }
    }
    @Environment(Settings.self) private var settings
    
    var body : some View {
        VStack {
            if realWeight != targetWeight {
                Text("No solution for \(targetWeight.formatted()) \(settings.weightUnit.short()).\nShowing closest possible weight: \(realWeight.formatted()) \(settings.weightUnit.short())")
                    .font(.headline)
                    .foregroundStyle(Color.red)
                    .multilineTextAlignment(.center)
                    .lineLimit(2, reservesSpace: true)
                    
                    
            }
            PlatesGraphicsView(plates: plates)
                                    .frame(height: 300)
            ScrollView(.vertical) {
                HStack {
                    ForEach(plates, id: \.weight) { plate in
                        VStack {
                            Text(plate.weight, format: .number)
                                .frame(width: 50, height: 50)
                                .background(plate.color.getAsColor())
                                .foregroundStyle(plate.color == .white ? .black : .white)
                                .clipShape(Circle())
                                .font(.system(.title3, design: .rounded, weight: .medium))
                            Text("×\(plate.count)")
                                .font(.system(.footnote, design: .rounded, weight: .semibold))
                        }
                    }
                }
            }
        }
    }
}

// TODO: keeping track of default barbell for different exercises!
struct PlateCalculator: View {
    var weight: Double = 108.5
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Barbell.weight) private var barbells: [Barbell]
    @Query(sort: \Plate.weight, order: .reverse) var availablePlates: [Plate] = []
    @State private var selectedBarbell: Barbell?
    @Environment(Settings.self) private var settings
    
    var solved: Candidate { // TODO: possibly async
        return plateCalculatorSolverCache.getCandidate(for: (weight - (selectedBarbell?.weight ?? 20)) / 2, plates: availablePlates)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                PlatesView(targetWeight: weight, realWeight: solved.usedWeight * 2 + (selectedBarbell?.weight ?? 20), candidate: solved)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                
                Section("Equipment") {
                    NavigationLink {
                        BarbellsView(barbells: barbells, selectedBarbell: $selectedBarbell)
                    } label: {
                        HStack {
                            Text("Barbell")
                            Spacer()
                            Text("\(selectedBarbell?.label ?? "Standard") (\(selectedBarbell?.weight.formatted() ?? "20") \(settings.weightUnit.short()))")
                                .foregroundStyle(.secondary)
                        }
                    }
                    NavigationLink {
                        AvailablePlatesView(plates: availablePlates)
                    } label: {
                        Text("Plates")
                    }
                }
                
            }.navigationTitle("Plate Calculator")
                .toolbar {
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            dismiss()
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
                .presentationDetents([.fraction(0.9)])
            
            
        }
        .onAppear {
            
            if selectedBarbell == nil {
                for barbell in barbells {
                    if barbell.weight == 20 && barbell.label == "Standard" {
                        selectedBarbell = barbell
                        break
                    }
                }
                if selectedBarbell == nil {
                    selectedBarbell = barbells.first
                }
            }
        }
        
    }
        
}

#Preview {
    NavigationStack {
        Text("Plate Calculator")
            .sheet(isPresented: .constant(true)) {
                PlateCalculator()
            }
    }
    .modelContainer(for: [Plate.self, Barbell.self], inMemory: true) { result in
        do {
            let container = try result.get()
            preloadBarbells(container)
            preloadPlates(container)
        } catch {
            print("Failed to create model container.")
        }
    }
    .environment(Settings())
}
