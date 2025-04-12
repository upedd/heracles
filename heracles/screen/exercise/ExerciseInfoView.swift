//
//  ExerciseInfoView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 14/02/2025.
//
import SwiftUI
import YouTubePlayerKit

struct ExerciseInfoView : View {
    @Bindable var exercise: Exercise
    
    // TODO: copy and pasted those from ExerciseEditor deduplicate them!
    var primaryMusclesLabel: String {
        let primaryMuscles = exercise.primaryMuscles
        if primaryMuscles.isEmpty {
            return "None"
        } else if exercise.primaryMuscles.count == 1 {
            return primaryMuscles.first!.displayName()
        } else {
            
            return primaryMuscles.prefix(primaryMuscles.count - 1).map { $0.displayName() }.joined(separator: ", ") + " and " + primaryMuscles.last!.displayName()
        }
    }
    
    var secondaryMusclesLabel: String {
        let secondaryMuscles = exercise.secondaryMuscles
        if secondaryMuscles.isEmpty {
            return "None"
        } else if secondaryMuscles.count == 1 {
            return secondaryMuscles.first!.displayName()
        } else {
            return secondaryMuscles.prefix(secondaryMuscles.count - 1).map { $0.displayName() }.joined(separator: ", ") + " and " + secondaryMuscles.last!.displayName()
        }
    }
    
    var equipmentLabel: String {
        let equipment = exercise.equipment
        if equipment.isEmpty {
            return "None"
        } else if equipment.count == 1 {
            return equipment.first!.displayName()
        } else {
            return equipment.prefix(equipment.count - 1).map { $0.displayName() }.joined(separator: ", ") + " and " + equipment.last!.displayName()
        }
    }
    
    var body : some View {
        List {
            if exercise.video != nil {
                StateHandlingYoutubePlayer(player: YouTubePlayer(urlString: exercise.video!))
                    .frame(height: 200)
                    .listRowInsets(EdgeInsets()) // removes default list item padding
            } else if exercise.images != nil && exercise.images!.count > 0 {
                AsyncImage(url: URL(string: exercise.images!.first!)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                    } else if let error = phase.error {
                        ContentUnavailableView(
                            "Error",
                            systemImage: "exclamationmark.triangle.fill",
                            description: Text("Image couldn't be loaded: \(error)")
                        )
                    }
                }
                .frame(height: 200)
                .listRowInsets(EdgeInsets()) // removes default list item padding
            }
            
            
            Section("Muscles") {
                HStack {
                    Text("Primary")
                    Spacer()
                    Text(primaryMusclesLabel)
                        .foregroundStyle(.secondary)
                }
                    HStack {
                        Text("Secondary")
                        Spacer()
                        Text(secondaryMusclesLabel)
                            .foregroundStyle(.secondary)
                    }
                
            }
            if !exercise.instructions.isEmpty {
                Section("Instructions") {
                    ForEach(exercise.instructions, id: \.self) { instruction in
                        Text(instruction)
                    }
                }
            }
            
            ExerciseNoteListView(exercise: exercise)
        }
    }
}

struct ExerciseNoteListView: View {
    @Bindable var exercise: Exercise
    @State private var showAddNote = false
    var body: some View {
        Section("Notes") {
            ForEach(exercise.pinnedNotes) { note in
                ExerciseNoteView(note: note) { note in
                    exercise.pinnedNotes.remove(at: exercise.pinnedNotes.firstIndex(of: note)!)
                }
            }
            .onDelete { indexSet in
                exercise.pinnedNotes.remove(atOffsets: indexSet)
            }
            Button {
                showAddNote.toggle()
            } label: {
                Label("Add Note", systemImage: "plus")
            }
        }
        .sheet(isPresented: $showAddNote) {
            AddNoteView(exercise: exercise)
        }
    }
}

struct ExerciseNoteView: View {
    var note: ExerciseNote
    var onDelete: (ExerciseNote) -> Void
    var body: some View {
        HStack {
            Text(note.text)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button {
                note.pinned.toggle()
                // TODO add haptics!
            } label: {
                Label(note.pinned ? "Unpin" : "Pin", systemImage: note.pinned ? "pin.fill" : "pin")
                    .contentTransition(.symbolEffect(.replace))
                    .sensoryFeedback(note.pinned ? .increase : .decrease, trigger: note.pinned)
            }
            .frame(alignment: .trailing)
            .labelStyle(.iconOnly)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contextMenu {
            Button {
                note.pinned.toggle()
            } label: {
                Label(note.pinned ? "Unpin" : "Pin", systemImage: note.pinned ? "pin.fill" : "pin")
                
            }
            Divider()
            Button(role: .destructive) {
                onDelete(note)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct AddNoteView: View {
    @Bindable var exercise: Exercise
    @State private var text = ""
    @State private var showCancelationWarning = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                TextEditorWithPlaceholder(text: $text, placeholder: "Note")
                    .frame(minHeight: 150)
            }
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        exercise.pinnedNotes.append(ExerciseNote(text: text))
                        dismiss()
                    }
                    .bold()
                    .disabled(text.isEmpty)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        if text.isEmpty {
                            dismiss()
                        } else {
                            showCancelationWarning.toggle()
                        }
                    }
                }
            }
            .confirmationDialog("Are you sure you want to discard this note?", isPresented: $showCancelationWarning) {
                Button("Discard Changes", role: .destructive) {
                    dismiss()
                }
                Button("Keep Editing", role: .cancel) {}
            }
            .presentationDetents([.medium])
            .interactiveDismissDisabled()
            .presentationBackgroundInteraction(.enabled)
                
        }
    }
}
