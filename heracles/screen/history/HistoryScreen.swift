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
// TODO: undo?

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
        var exercises: [Exercise]
        var body: some View {
            ZStack {
                VStack {
                    HStack(alignment: .top) {
                        WorkoutIconView(exercises: workout.exercises)
                            .frame(width: 45, height: 45)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.trailing, 10)
                        VStack(alignment: .leading) {
                            HStack(alignment: .top) {
                                Text(workout.name)
                                    .font(.system(.headline, weight: .medium))
                                Spacer()
                                Text(workout.date.formatted(.dateTime.day().month(.defaultDigits).year()))
                                    .font(.system(.caption, weight: .medium))
                                    .foregroundStyle(Color(.secondaryLabel))
                            }
                            .padding(.bottom, 1)
                            ForEach(workout.exercises) { exercise in
                                
                                Text("\(exercise.sets.count) × \(exercise.exercise.name)")
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                            }
                        }
                        
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                }
                .background(Material.regular)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
                NavigationLink {
                    WorkoutView(workout: workout, exercises: exercises)
                } label: {
                    EmptyView()
    
                }
                .opacity(0)
                    
            }
            
        }
    }
    
    var startEmptyWorkout: () -> Void
    
    @Query(sort: \Workout.date, order: .reverse) private var workouts: [Workout]
    
    var loggedWorkouts: [Workout] {
        workouts.filter { !$0.active }
    }
    @Environment(\.modelContext) private var modelContext
    var groupedWorkouts: [Date: [Workout]] {
        Dictionary(grouping: loggedWorkouts.filter {!$0.active}, by: {
            let components = Calendar.current.dateComponents([.month, .year], from: $0.date)
            return Calendar.current.date(from: components)!
        })
    }
    
    @State private var selectedDateComponents: DateComponents?
    @State private var isShowingCalendar = false
    private var selectedDateWorkouts: [Workout]? {
        if let selectedDate = selectedDateComponents?.date {
                return loggedWorkouts.filter {
                    !$0.active && Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
                }
            }
            return nil
    }
    
    private var calendarDecorationsDateComponents: Set<DateComponents> {
        return Set(loggedWorkouts.map { workout in
            Calendar.current.dateComponents([.day, .month, .year], from: workout.date)
        })
    }
    
    @State private var isLoggingPastWorkout = false
    @Query private var exercises: [Exercise]
    
    var body: some View {
        NavigationStack {
                
                List {
                    if isShowingCalendar {
                        if !loggedWorkouts.isEmpty {
                            CalendarView(selection: $selectedDateComponents)
                                .decorating(calendarDecorationsDateComponents, color: .blue)
                        }
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
                                    WorkoutItem(workout: workout, exercises: exercises)
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
                                        WorkoutItem(workout: workout, exercises: exercises)
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
                    if loggedWorkouts.isEmpty && !isShowingCalendar {
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
                    NewWorkoutView(date: selectedDateComponents?.date ?? Date.now)
                        
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
            for i in 0..<10 {
                container.mainContext.insert(Workout.sample)
            }
        } catch {
            print("Error!")
        }
    }
}
