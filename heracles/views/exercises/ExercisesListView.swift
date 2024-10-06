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
    @Binding var selection: Swift.Set<String>
    @Binding var youtubeVideoUrl: String
    
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
                    List(Exercise.muscleGroups.filter {$0 != targetMuscleGroup}, id: \.self, selection: $selection) { group in
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
            selection.remove(targetMuscleGroup)
        }
    }
}

struct ExerciseListView: View {
    @Query(sort: \Exercise.name)
    private var exercises: [Exercise]
    
    @Environment(\.modelContext)
    private var context
    
    @State
    private var showAddExerciseDialog = false
    
    @State private var name = ""
    @State private var instructions = ""
    @State private var targetMuscleGroup = "Other"
    @State private var selection = Swift.Set<String>()
    @State private var youtubeVideoUrl = ""
    
    @State
    private var showDiscardWarning = false
    
    var body: some View {
        NavigationStack {
            List(exercises) { exercise in
                Text(exercise.name)
            }
            .navigationTitle("Exercises")
            .toolbar {
                Button("Add exercise", systemImage: "plus") {
                    showAddExerciseDialog = true
                }
                .labelStyle(.iconOnly)
            }
            .sheet(isPresented: $showAddExerciseDialog) {
//                if hasNoChanges() {
//                    showAddExerciseDialog = false
//                } else {
//                    showDiscardWarning = true
//                }
            } content: {
                NavigationStack {
                    ExerciseEditView(name: $name, instructions: $instructions, targetMuscleGroup: $targetMuscleGroup, selection: $selection, youtubeVideoUrl: $youtubeVideoUrl)
                        .navigationTitle("New Exercise")
                        .toolbar {
                            ToolbarItemGroup(placement: .cancellationAction) {
                                Button("Cancel") {
                                    if hasNoChanges() {
                                        showAddExerciseDialog = false
                                    } else {
                                        showDiscardWarning = true
                                    }
                                }
                            }
                            ToolbarItemGroup(placement: .confirmationAction) {
                                Button("Done") {
                                    let exercise = Exercise(name: name)
                                    exercise.instructions = instructions
                                    exercise.selection = Array(selection)
                                    exercise.targetMuscleGroup = targetMuscleGroup
                                    exercise.youtubeVideoUrl = youtubeVideoUrl
                                    context.insert(exercise)
                                    clearAddForm()
                                    showAddExerciseDialog = false
                                }.disabled(name.isEmpty)
                            }
                        }
                        .toolbarTitleDisplayMode(.inline)
                        .interactiveDismissDisabled(!hasNoChanges()) {
                            showDiscardWarning.toggle()
                        }
                        .confirmationDialog("Are you sure you want to discard this new exercise?", isPresented: $showDiscardWarning, titleVisibility: .visible) {
                            Button("Discard Changes", role: .destructive) {
                                clearAddForm()
                                showAddExerciseDialog = false
                            }
                            Button("Keep Editing", role: .cancel) {
                            }
                        }
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

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Workout.self, configurations: config)
    
    prepopulateExercises(context: container.mainContext)
    
    return ExerciseListView()
            .modelContainer(container)
}
