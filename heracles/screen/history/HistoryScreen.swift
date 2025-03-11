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
                    WorkoutIconView(workout: workout)
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
    
    @Query(sort: \Workout.date, order: .reverse) private var workouts: [Workout]
    @Environment(\.modelContext) private var modelContext
    var groupedWorkouts: [Date: [Workout]] {
        Dictionary(grouping: workouts, by: {
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
                    Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
                }
            }
            return nil
    }
    
    // TODO: adding workouts!
    // TODO: workout deletion warning!
    
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
                                    Button("Add Workout") {
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
                            Button("Start Workout") {
                                
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
            
            .toolbar {
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
                EditButton()
            }
            .listStyle(.plain)
            .listRowSeparator(.hidden)
            .navigationTitle("History")
            
        }
    }
}


#Preview {
    
    
    
    HistoryScreen()    .modelContainer(for: Workout.self, inMemory: true) { result in
        do {
            let container = try result.get()
            for i in 0..<100 {
                container.mainContext.insert(Workout.sample)
            }
        } catch {
            print("Error!")
        }
    }
}
