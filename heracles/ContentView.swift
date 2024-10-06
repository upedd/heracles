//
//  ContentView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 04/10/2024.
//

import SwiftUI
import SwiftData



struct StartWorkoutDialog: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
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
        context.insert(Workout(name: name, date: Date.now))
        dismiss()
    }
}


struct WorkoutListItem: View {
    @Bindable var workout: Workout
    
    var body: some View {
        NavigationLink {
            ActiveWorkoutView(workout: workout)
        } label: {
            VStack(alignment: .leading) {
                Text(workout.name)
                    .font(.headline)
                Text(workout.date, format: .dateTime)
                    .font(.subheadline)
            }
        }
        
    }
}
@Observable
class Book: Identifiable {
    var title = "Sample Book Title"
    var isAvailable = true
}

struct LibraryView: View {
    @State private var books = [Book(), Book(), Book()]


    var body: some View {
        List(books) { book in
            @Bindable var book = book
            TextField("Title", text: $book.title)
        }
    }
}


struct WorkoutList: View {
    @Query
    private var workouts: [Workout]
    
    @State private var showStartWorkoutSheet = false
    var body: some View {
        NavigationStack {
            List(workouts) { workout in
                WorkoutListItem(workout: workout)
            }
            .navigationTitle("Workouts")
            .toolbar {
                Button("Start") {
                    showStartWorkoutSheet.toggle()
                }
            }
            .sheet(isPresented: $showStartWorkoutSheet) {
                StartWorkoutDialog()
            }
        }
    }
}

struct ContentView: View {
    
    @Environment(\.modelContext) private var context
    
    var body: some View {
            TabView {
                Tab("Workouts", systemImage: "dumbbell") {
                    WorkoutList()
                }
                Tab("Exercises", systemImage: "books.vertical") {
                    ExerciseListView()
                }

            }.onAppear {
                prepopulateExercises(context: context)
            }
        
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
