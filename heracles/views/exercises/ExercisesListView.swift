//
//  ExercisesListView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 06/10/2024.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

// TODO: equipment
// TODO: type
// TODO: resources
// TODO: notes
// TODO: dialog disacrd alert!

struct ExerciseEditView: View {
    
    @Binding var name: String
    @Binding var instructions: String
    @Binding var targetMuscleGroup: String
    @Binding var selection: [String]
    @Binding var youtubeVideoUrl: String
    
    @State var selectionState = Swift.Set<String>()
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                Picker("Target Muscle Group", selection: $targetMuscleGroup) {
                    ForEach(Exercise.muscleGroups, id: \.self) {
                        Text($0)
                    }
                }
                
            }
            Section {
                ZStack(alignment: .topLeading) {
                    if instructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text("Instructions").foregroundColor(Color(UIColor.placeholderText)).padding(.top, 8)
                    }
                    TextEditor(text: $instructions).padding(.leading, -3)
                }
            }
            Section("Secondary Muscles") {
                NavigationLink(selection.isEmpty ? "None" : selection.joined(separator: ", ")) {
                    List(Exercise.muscleGroups.filter {$0 != targetMuscleGroup}, id: \.self, selection: $selectionState) { group in
                        Text(group)
                    }
                    .navigationTitle("Select Muscles")
                    .toolbarTitleDisplayMode(.inline)
                    .environment(\.editMode, Binding.constant(EditMode.active))
                }
                
                
            }
            
            Section("Youtube Video URL") {
                HStack {
                    // TODO: add validation!
                    TextField("URL: ", text: $youtubeVideoUrl, prompt: Text(verbatim: "https://youtube.com/watch?v="))
                }
            }
        }
        .onChange(of: targetMuscleGroup) {
            selectionState.remove(targetMuscleGroup)
        }
        .onChange(of: selectionState) {
            selection = Array(selectionState)
        }
    }
}

struct NewExerciseView : View {
    
    @State private var name = ""
    @State private var instructions = ""
    @State private var targetMuscleGroup = "Other"
    @State private var selection = [String]()
    @State private var youtubeVideoUrl = ""
    
    @State
    private var showDiscardWarning = false
    
    @Environment(\.modelContext)
    private var context
    
    @Environment(\.dismiss)
    private var dismiss
    
    var body: some View {
        NavigationStack {
            ExerciseEditView(name: $name, instructions: $instructions, targetMuscleGroup: $targetMuscleGroup, selection: $selection, youtubeVideoUrl: $youtubeVideoUrl)
                .navigationTitle("New Exercise")
                .toolbar {
                    ToolbarItemGroup(placement: .cancellationAction) {
                        Button("Cancel") {
                            if hasNoChanges() {
                                dismiss()
                            } else {
                                showDiscardWarning = true
                            }
                        }
                    }
                    ToolbarItemGroup(placement: .confirmationAction) {
                        Button("Done") {
                            let exercise = Exercise(name: name)
                            exercise.instructions = instructions
                            exercise.selection = selection
                            exercise.targetMuscleGroup = targetMuscleGroup
                            exercise.youtubeVideoUrl = youtubeVideoUrl
                            context.insert(exercise)
                            clearAddForm()
                            dismiss()
                        }.disabled(name.isEmpty)
                    }
                }
                .toolbarTitleDisplayMode(.inline)
                .interactiveDismissDisabled() // TODO: add support for swipe to dismiss with warning! (currently requires UIKit)
                .confirmationDialog("Are you sure you want to discard this new exercise?", isPresented: $showDiscardWarning, titleVisibility: .visible) {
                    Button("Discard Changes", role: .destructive) {
                        clearAddForm()
                        dismiss()
                    }
                    Button("Keep Editing", role: .cancel) {
                    }
                }
        }
        
    }
    
    func clearAddForm() {
        instructions = ""
        selection.removeAll()
        targetMuscleGroup = "Other"
        youtubeVideoUrl = ""
        name = ""
        
    }
    
    func hasNoChanges() -> Bool {
        return instructions.isEmpty && selection.isEmpty && targetMuscleGroup == "Other" && youtubeVideoUrl.isEmpty && name.isEmpty
    }
}



struct ExerciseListView: View {
    @Query(sort: \Exercise.name)
    private var exercises: [Exercise]
    
    
    
    @State
    private var showAddExerciseDialog = false
    
    var body: some View {
        NavigationStack {
            List(exercises) { exercise in
                NavigationLink(destination: ExerciseView(exercise: exercise)) {
                    Text(exercise.name)
                }
            }
            .navigationTitle("Exercises")
            .toolbar {
                Button("Add exercise", systemImage: "plus") {
                    showAddExerciseDialog = true
                }
                .labelStyle(.iconOnly)
            }
            .sheet(isPresented: $showAddExerciseDialog) {
                NewExerciseView()
            }
            
        }
    }
    
    
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Workout.self, configurations: config)
    
    prepopulateExercises(context: container.mainContext)
    
    return ExerciseListView()
            .modelContainer(container)
}
