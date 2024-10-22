//
//  ContentView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 04/10/2024.
//

import SwiftUI
import SwiftData
import LNPopupUI


struct StartWorkoutDialog: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var ctx: AppContext
    
    @State private var name = ""
    @FocusState private var isNameFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                
                TextField(text: $name) {
                    Text("Workout name")
                }
                .focused($isNameFocused)
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add", action: addWorkout)
                        .fontWeight(.bold)
                }
            }
            .navigationTitle("New Workout")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            isNameFocused = true
        }
    }
    
    func addWorkout() {
        let workout = Workout(name: name, date: Date.now)
        context.insert(workout)
        ctx.activeWorkout = workout
        ctx.popupBarVisible = true
        ctx.popupBarOpen = true
        dismiss()
    }
}


struct WorkoutListItem: View {
    @Bindable var workout: Workout
    @EnvironmentObject var workoutPath: WorkoutPath
    var body: some View {
        Button {
            workoutPath.path.append(workout)
        } label: {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    Text(workout.name)
                        .font(.body)
                    Group { // Note: possibly remove
                        if workout.duration != nil {
                            Text(workout.duration!.formatted(.time(pattern: .hourMinuteSecond)))
                        } else {
                            Text("0:48:03")
                        }
                    }
                    .foregroundStyle(Color.accentColor)
                    .font(.title)
                }
                Spacer()
                VStack {
                    Spacer()
                    Text(workout.date, format: .dateTime)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 15)
            .padding(.bottom, 15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Material.regular)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(PlainButtonStyle())
        
        
    }
}


struct WorkoutListHeader: View {
    var name: String
    
    var body: some View {
        HStack {
            Text(name)
                .font(.title2.bold())
                .foregroundStyle(Color.primary)
                .padding(.leading, 20)
                .padding(.vertical, 10)
            Spacer()
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .background(Color(UIColor.systemBackground))
    }
}
class WorkoutPath: ObservableObject {
    @Published var path = NavigationPath()
}

// TODO: custom preview on long press
struct WorkoutList: View {
    @Query(sort: \Workout.date, order: .reverse)
    private var workouts: [Workout]
    @State private var workoutsDict: Dictionary<String, [Workout]> = [:]
    @StateObject private var workoutPath = WorkoutPath()
    var body: some View {
        NavigationStack(path: $workoutPath.path) {
            List(Array(workoutsDict.keys), id: \.self) { group in
                Section {
                    ForEach(workoutsDict[group]!.filter {$0.finished}) { workout in
                        WorkoutListItem(workout: workout)
                    }
                    .listRowSeparator(.hidden)
                } header: {
                    WorkoutListHeader(name: group)
                }
                
            }
            .environmentObject(workoutPath)
            .navigationTitle("History")
            .listStyle(.plain)
            .navigationDestination(for: Workout.self) { workout in
                WorkoutView(workout: workout)
            }
        }.onChange(of: workouts) { _, _ in
            workoutsDict = Dictionary(grouping: workouts, by: {$0.date.formatted(.dateTime.month(.wide).year())})
        }.onAppear {
            workoutsDict = Dictionary(grouping: workouts, by: {$0.date.formatted(.dateTime.month(.wide).year())})
        }
    }
}

struct PopupContent :  View {
    @State var now = Date.now
    @Query(sort: \Workout.date, order: .reverse)
    private var workouts: [Workout]
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var futureDate = Date.now.addingTimeInterval(60 * 60 * 24)
    var body: some View {
        //Text("Hello World!")
        if !workouts.isEmpty {
            let timeFormatter = SystemFormatStyle.Timer(countingUpIn: workouts.first!.date..<futureDate)
            NavigationStack {
                ActiveWorkoutView(workout: workouts.first!, durationDisplay: String(timeFormatter.format(now).characters))
                    .popupTitle {
                        VStack(alignment: .leading) {
                            
                            Text(workouts.first!.name)
                            
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    } subtitle: {
                        VStack(alignment: .leading) {
                            Text(now, format: timeFormatter)
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                
            }.onReceive(timer) { _ in
                now = Date.now
            }
        }
    }
    
}

struct StartWorkoutView: View {
    @EnvironmentObject var ctx: AppContext
    
    @State private var showAddWorkout = false
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Button {
                        showAddWorkout = true
                    } label: {
                        HStack {
                            Spacer()
                            
                            Label {
                                Text(ctx.activeWorkout == nil ? "Start Empty Workout" : "Workout In Progress")
                            } icon: {
                                if ctx.activeWorkout == nil {
                                    Image(systemName: "plus.circle.fill")
                                } else {
                                    Image(systemName: "record.circle")
                                        .symbolEffect(.breathe)
                                }
                            }.font(.headline)
                                .padding(.all, 8.0)
                            
                            Spacer()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    .disabled(ctx.activeWorkout != nil)
                    Text("Templates (WIP 🚧)")
                        .font(.title2.bold())
                        .padding()
                }
            }.navigationTitle("Workout")
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .sheet(isPresented: $showAddWorkout) {
                    StartWorkoutDialog()
                }
        }
    }
}

class AppContext: ObservableObject {
    @Published var activeWorkout: Workout?
    @Published var popupBarVisible = false
    @Published var popupBarOpen = false
}

struct ContentView: View {
    @Environment(\.modelContext) private var context
    
    @Query(sort: \Workout.date, order: .reverse)
    private var workouts: [Workout]
    @StateObject var appContext = AppContext()
    
    var body: some View {
        TabView {
            Tab("Workout", systemImage: "dumbbell") {
                StartWorkoutView()
            }
            Tab("Exercises", systemImage: "books.vertical") {
                ExerciseListView()
            }
            Tab("History", systemImage: "clock") {
                WorkoutList()
            }
        }
        .popup(isBarPresented: $appContext.popupBarVisible, isPopupOpen: $appContext.popupBarOpen) {
            PopupContent()
        }
        .onAppear {
            prepopulateExercises(context: context)
            initActiveWorkout()
        }
        .environmentObject(appContext)
    }
    
    func initActiveWorkout() {
        guard !workouts.isEmpty && !workouts.first!.finished else {
            return
        }
        appContext.activeWorkout = workouts.first
        appContext.popupBarVisible = true
    }
}

func prepopulateExercises(context: ModelContext) {
    print("Hello world!")
    // TODO: what to do if nil
    let exerciseCount = try? context.fetchCount(FetchDescriptor<Exercise>())
    
    guard exerciseCount == 0 else {
        return
    }
    print("Population")
    
    let exercises = [
        Exercise(name: "Dumbell row"),
        Exercise(name: "Bench press"),
        Exercise(name: "Deadlift"),
        Exercise(name: "Chinups"),
        Exercise(name: "Overhead press")
    ]
    
    for exercise in exercises {
        context.insert(exercise)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Workout.self)
}
