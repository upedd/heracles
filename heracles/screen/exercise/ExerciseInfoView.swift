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
    
    var body : some View {
        List {
            if exercise.youtubeVideoURL != nil {
                StateHandlingYoutubePlayer(player: YouTubePlayer(urlString: exercise.youtubeVideoURL!))
                    .frame(height: 200)
                    .listRowInsets(EdgeInsets()) // removes default list item padding
            }
            
            
            Section("Muscles") {
                HStack {
                    Text("Primary")
                        .font(.headline)
                    Spacer()
                    Text(exercise.primaryMuscleGroup.displayName())
                }
                if exercise.secondaryMuscleGroups.count > 0 {
                    HStack {
                        Text("Secondary")
                            .font(.headline)
                        Spacer()
                        Text(exercise.secondaryMuscleGroups.map {$0.displayName()}.joined(separator: ", "))
                    }
                }
            }
            if exercise.instructions != nil {
                Section("Instructions") {
                    ForEach(exercise.instructions!.components(separatedBy: "\n"), id: \.self) { instruction in
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
