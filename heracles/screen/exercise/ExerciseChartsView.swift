//
//  ExerciseChartsView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 14/02/2025.
//

import SwiftUI
import Charts
import SwiftData

// TODO: improve mini charts
// TODO: add more charts
// TODO: add insights

struct ExerciseChartsCardView : View {
    struct ChartCard : View {
        var title: String
        var data: [ChartData]
        var unit: String
        var type: ChartType
        var function: ChartFunction
        
        var lastMonthData: [ChartData] {
            data.filter {
                $0.date > Date.now.addingTimeInterval(-60*60*24*14)
            }
        }
        
        var body : some View {
            NavigationLink {
                ExerciseChartView(title: title, data: data, type: type, function: function)
            } label: {
                VStack(alignment: .leading) {
                    HStack {
                        Text(title)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(Color(uiColor: UIColor.systemBlue))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.tertiary)
                            .fontWeight(.semibold)
                            .imageScale(.small)
                    }
                    HStack {
                        
                        VStack(alignment: .leading) {
                            Spacer()
                            if !data.isEmpty {
                                HStack(alignment: .firstTextBaseline) {
                                    Text(data.first!.value.formatted())
                                        .font(.system(.largeTitle, design: .rounded, weight: .medium))
                                    Text("kg")
                                        .font(.headline.bold())
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .frame(alignment: .bottom)
                        Spacer()
                        if !data.isEmpty {
                            Chart {
                                ForEach(lastMonthData, id: \.date) { entry in
                                    if (entry.date == data.first!.date) {
                                        if type == .line {
                                            LineMark(
                                                x: .value("Date", entry.date, unit: .day),
                                                y: .value("Volume", entry.value)
                                            )
                                                .foregroundStyle(Color.gray.opacity(0.3))
                                            PointMark(
                                                x: .value("Date", entry.date, unit: .day),
                                                y: .value("Volume", entry.value)
                                            ).foregroundStyle(Color.blue)
                                        } else {
                                            BarMark(
                                                x: .value("Date", entry.date, unit: .day),
                                                y: .value("Volume", entry.value)
                                            ).foregroundStyle(Color.blue)
                                        }
                                        
                                    } else {
                                        if type == .line {
                                            LineMark(
                                                x: .value("Date", entry.date, unit: .day),
                                                y: .value("Volume", entry.value)
                                            )
                                            .foregroundStyle(Color.gray.opacity(0.3))
                                        } else {
                                            BarMark(
                                                x: .value("Date", entry.date, unit: .day),
                                                y: .value("Volume", entry.value)
                                            )
                                            .foregroundStyle(Color.gray.opacity(0.3))
                                        }
                                        
                                        
                                    }
                                }
                            }
                            .chartXVisibleDomain(length: 86400 * 14)
                            .chartXAxis(.hidden)
                            .chartYAxis(.hidden)
                            .frame(width: 70, height: 50)
                            .padding(.trailing, 5)
                        }
                    }
                }
                .padding()
                .background(Material.regular)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundColor(.primary)
            }
        }
    }
    
    var exercise: Exercise
    @Query var workoutsExercises: [WorkoutExercise]
    
    var filteredWorkoutExercises: [WorkoutExercise] {
        workoutsExercises.filter {
            $0.exercise == exercise
        }
        .sorted {
            $0.workout!.date > $1.workout!.date
        }
    }
    
    var volumeData: [ChartData] {
        filteredWorkoutExercises
            .map {
                ChartData(
                    value: $0.sets.reduce(0) { $0 + $1.weight! },
                    date: $0.workout!.date
                    
                )
            }
    }
    var bestWeightData: [ChartData] {
        filteredWorkoutExercises
            .map {
                let bestSet = $0.sets.max { $0.weight! < $1.weight! }
                return ChartData(
                    value: bestSet!.weight!,
                    date: $0.workout!.date
                )
            }
    }
    
    var bestSetData: [ChartData] {
        filteredWorkoutExercises
            .map {
                let bestSet = $0.sets.max { $0.weight! < $1.weight! }
                return ChartData(
                    value: bestSet!.weight! * Double(bestSet!.reps!),
                    date: $0.workout!.date
                )
            }
    }
    
    var estimated1RMData: [ChartData] {
        filteredWorkoutExercises
            .map {
                let bestSet = $0.sets.max { $0.weight! < $1.weight! }
                return ChartData(
                    value: oneRepMax(reps: bestSet!.reps!, weight: bestSet!.weight!).rounded(), // TODO: better rounding!
                    date: $0.workout!.date
                )
            }
    }
    
    var body: some View {
        ScrollView {
            if !filteredWorkoutExercises.isEmpty {
                VStack(spacing: 10) {
                    ChartCard(title: "Volume", data: volumeData, unit: "kg", type: .bar, function: .sum)
                    ChartCard(title: "Estimated 1RM", data: estimated1RMData, unit: "kg", type: .line, function: .max)
                    ChartCard(title: "Best Weight", data: bestWeightData, unit: "kg", type: .line, function: .max)
                    ChartCard(title: "Best Set Volume", data: bestSetData, unit: "kg", type: .line, function: .max)
                }
            } else {
                ContentUnavailableView {
                    Label("No Logged Sets", systemImage: "archivebox")
                } description: {
                    Text("Charts for this exercise will appear once you log a set.")
                }
            }
        }
    }
}

struct ExerciseChartsView: View {
    var exercise: Exercise
    var body: some View {
        ScrollView {
            ExerciseChartsCardView(exercise: exercise)
        }
        .padding()
    }
}

#Preview {
    let exercise = Exercise.sample
    NavigationStack {
        ExerciseChartsView(exercise: exercise)
    }
    .modelContainer(for: Workout.self, inMemory: true) { result in
        do {
            let container = try result.get()
            container.mainContext.insert(exercise)
            for i in 0..<100 {
                let workout = Workout.sample
                workout.exercises.first?.exercise = exercise
                container.mainContext.insert(workout)
            }
            
        } catch {
            print("Error!")
        }
    }
}
