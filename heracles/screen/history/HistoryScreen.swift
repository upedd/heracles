//
//  HistoryScreen.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 13/02/2025.
//

import SwiftUI
import SwiftData

// TODO: PRIMARY: tweak visuals still

// TODO: maybe do something on longpress workout?
// TODO: some filtering
// TODO: month by month statstics look fitness app

struct HistoryScreen: View {
    struct DateHeader: View {
        var title: String
        var body: some View {
            HStack {
                Text(title)
                    .font(.title2.bold())
                    .foregroundStyle(Color.primary)
                    .padding(.leading, 20)
                    .padding(.vertical, 10)
                Spacer()
            }
            .listRowInsets(EdgeInsets())
            .background(Color(.systemBackground))
        }
    }
    
    struct WorkoutItem: View {
        var workout: Workout
        var body: some View {
            ZStack {
                HStack(alignment: .center) {
                    WorkoutIconView(exercises: workout.exercises)
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.trailing, 10)
                    VStack(alignment: .leading) {
                        HStack(alignment: .top){
                            Text(workout.name)
                                .font(.body)
                            Spacer()
                                Text(workout.date.formatted(.dateTime))
                                    .font(.system(.caption2, design: .rounded))
                                    .foregroundStyle(Color(.secondaryLabel))
                        }
                        .padding(.bottom, 1)
                        
                        Text("\(workout.exercises.map(\.exercise.name).joined(separator: ", "))")
                            .font(.system(.footnote, design: .rounded, weight: .light))
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    
                }
                .padding()
                .background(Material.regular)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
                NavigationLink {
                    WorkoutView(workout: workout)
                } label: {
                    EmptyView()
    
                }
                .opacity(0)
                    
            }
            
        }
    }
    
    var startEmptyWorkout: () -> Void
    
    @Query(sort: \Workout.date, order: .reverse) private var workouts: [Workout]
    @Environment(\.modelContext) private var modelContext
    var groupedWorkouts: [Date: [Workout]] {
        Dictionary(grouping: workouts.filter {!$0.active}, by: {
            let components = Calendar.current.dateComponents([.month, .year], from: $0.date)
            return Calendar.current.date(from: components)!
        })
    }
    
    @State private var selectedDateComponents: DateComponents?
    
    private var selectedDate: Date? {
        selectedDateComponents?.date
    }

    @State private var isShowingCalendar = false
    
    private var selectedDateWorkouts: [Workout]? {
            if let selectedDate {
                return workouts.filter {
                    !$0.active && Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
                }
            }
            return nil
    }
    // TODO: workout deletion warning!
    
    @State private var isLoggingPastWorkout = false
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                
                List {
                    
                    if isShowingCalendar {
                        if !workouts.isEmpty { // TODO: calendar doesn't respond to changes
                            CalendarView(workouts: workouts, interval: DateInterval(start: .distantPast, end: .distantFuture), dateSelected: $selectedDateComponents)
                                .frame(height: 430)
                                .listRowSeparator(.hidden)
                        }
    
                            
                            //.padding()
                        if selectedDateWorkouts != nil {
                            if selectedDateWorkouts!.isEmpty {
                                // think about this, see hig guidelines!
                                ContentUnavailableView {
                                                        Label("No Workouts on this day", systemImage: "calendar.badge.exclamationmark")
                                } actions: {
                                    Button("Log Past Workout") {
                                        isLoggingPastWorkout.toggle()
                                    }
                                    .buttonStyle(.borderless)
                                }
                                .listRowSeparator(.hidden)
                            } else {
                                ForEach(selectedDateWorkouts!) { workout in
                                    WorkoutItem(workout: workout)
                                        .id(workout)
                                    
                                }
                                .onDelete { indexSet in
                                    indexSet.map { selectedDateWorkouts![$0] }.forEach { workout in
                                        modelContext.delete(workout)
                                    }
                                }
                                .listRowSeparator(.hidden)
                            }
                        }
                            
                    } else {
                        
                            ForEach(Array(groupedWorkouts.keys).sorted().reversed(), id: \.self) { key in
                                Section {
                                    ForEach(groupedWorkouts[key]!) { workout in
                                        WorkoutItem(workout: workout)
                                            .id(workout)
                                    }
                                    
                                    .onDelete { indexSet in
                                        indexSet.map { groupedWorkouts[key]![$0] }.forEach { workout in
                                            modelContext.delete(workout)
                                        }
                                    }
                                    .listRowSeparator(.hidden)
                                } header: {
                                    DateHeader(title: key.formatted(.dateTime.month(.wide).year()))
                                }
                            }
                        
                            
                    }
                }
                .overlay {
                    if workouts.isEmpty {
                        ContentUnavailableView {
                            Label("No Workouts", systemImage: "archivebox")
                        } description: {
                            Text("Your workouts will appear here")
                        } actions: {
                            Menu("Add Workout", systemImage: "plus") {
                                Button("Start Empty Workout", systemImage: "bolt.fill") {
                                    startEmptyWorkout()
                                }
                                // TODO: start workout from template
                                Button("Log Past Workout", systemImage: "archivebox.fill") {
                                    isLoggingPastWorkout.toggle()
                                }
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
            
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if isShowingCalendar {
                        Button {
                            isShowingCalendar = false
                        
                        } label: {
                            Label("List", systemImage: "list.bullet")
                        }
                    } else {
                        Button {
                            isShowingCalendar = true
                        } label: {
                            Label("Calendar", systemImage: "calendar")
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu("Add Workout", systemImage: "plus") {
                        Button("Start Empty Workout", systemImage: "bolt.fill") {
                                startEmptyWorkout()
                        }
                        // TODO: start workout from template
                        Button("Log Past Workout", systemImage: "archivebox.fill") {
                            isLoggingPastWorkout.toggle()
                        }
                    }
                }
            }
            .sheet(isPresented: $isLoggingPastWorkout) {
                NavigationStack {
                    NewWorkoutView(date: selectedDate)
                }
            }
            .listStyle(.plain)
            .listRowSeparator(.hidden)
            .navigationTitle("History")
            
        }
    }
}


#Preview {
    
    
    
    HistoryScreen(startEmptyWorkout: {})    .modelContainer(for: Workout.self, inMemory: true) { result in
        do {
            let container = try result.get()
            preloadExercises(container)
            for i in 0..<0 {
                container.mainContext.insert(Workout.sample)
            }
        } catch {
            print("Error!")
        }
    }
}
