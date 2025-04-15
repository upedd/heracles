//
//  WorkoutScreen.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 13/02/2025.
//

import SwiftUI
import SwiftData

// TODO: this is very basic implementatinon of workout templates,
// lots to improve and polish!

// TODO: templates folders!
// fix visuals
// too much padding on card
// weird padding on borders

struct TemplateDetailsView : View {
    @Bindable var template: WorkoutTemplate
    @State private var name: String
    @Environment(\.dismiss) private var dismiss
    @State private var showCancellationWarning = false
    
    init(template: WorkoutTemplate, name: String) {
        self.template = template
        self.name = name
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Template Name", text: $name)
            }
            .navigationTitle("Template Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if template.name != name {
                            showCancellationWarning.toggle()
                        } else {
                            dismiss()
                        }
                    } label: {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        template.name = name
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                    .disabled(name.isEmpty)
                    .fontWeight(.bold)
                }
            }
            .confirmationDialog("Are you sure you want to discard this template?", isPresented: $showCancellationWarning, titleVisibility: .hidden) {
                Button("Discard Changes", role: .destructive) {
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
}

struct TemplateView : View {
    @Bindable var template: WorkoutTemplate
    @Environment(\.dismiss) var dismiss
    @State private var isEditing = false
    @State private var isAddingExercises = false
    @State private var showDetails = false
    @State private var showDeleteAlert = false
    @Environment(\.modelContext) private var modelContext
    @State private var showDuplicateTemplate = false
    
    var startWorkout: ([WorkoutExercise], String?) -> Void
    var body : some View {
        List {
            ForEach(template.exercises) { exercise in
                NavigationLink {
                    WorkoutExerciseView(exercise: exercise, active: false, isInTemplate: true)
                } label: {
                    Text(exercise.exercise.name)
                }
            }
            .onDelete { indexSet in
                template.exercises.remove(atOffsets: indexSet)
            }
            .onMove { indices, newOffset in
                template.exercises.move(fromOffsets: indices, toOffset: newOffset)
            }
            if isEditing {
                Button {
                    isAddingExercises.toggle()
                } label: {
                    Label("Add Exercises", systemImage: "plus")
                }
                .sheet(isPresented: $isAddingExercises) {
                    SelectExercisesView(onDone: { selected in
                        for exercise in selected {
                            template.exercises.append(WorkoutExercise(exercise: exercise))
                        }
                    })
                }
            }
        }
        .navigationTitle(template.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditing {
                    Button("Done") {
                        isEditing = false
                    }
                } else {
                    Menu {
                        Button("Show Template Info", systemImage: "info.circle") {
                            showDetails.toggle()
                        }
                        Button("Edit Exercises", systemImage: "pencil") {
                            isEditing = true
                        }
                        // TODO: swap views on duplicate
                        Button("Duplicate", systemImage: "plus.rectangle.on.rectangle") {
                            showDuplicateTemplate.toggle()
                        }
                        Button("Delete Template", systemImage: "trash", role: .destructive) {
                            showDeleteAlert.toggle()
                        }
                        
                    } label: {
                        Label("Actions", systemImage: "ellipsis.circle")
                    }
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Button {
                    startWorkout(template.exercises, template.name)
                } label: {
                    Label("Start Workout", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                        .padding(.all, 8)
                }
                .labelStyle(.titleAndIcon)
                .buttonStyle(.borderedProminent)
            }
        }
        .sheet(isPresented: $showDuplicateTemplate) {
            NewWorkoutTemplateView(name: "\(template.name) Copy", exercises: template.exercises) // check if should manually copy exercises!
        }
        .sheet(isPresented: $showDetails) {
            TemplateDetailsView(template: template, name: template.name)
        }
        .alert("Delete Template \"\(template.name)\"?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                modelContext.delete(template)
                dismiss()
            }
            
        } message: {
            Text("This action cannot be undone.")
        }
        .environment(\.editMode, isEditing ? .constant(.active) : .constant(.inactive))
    }
}



struct WorkoutTemplateCard : View {
    @Bindable var template: WorkoutTemplate
    var startWorkout: ([WorkoutExercise], String?) -> Void
    var isSelecting: Bool
    var isSelected: Bool
        var body : some View {
        ZStack {
            WorkoutIconView(exercises: template.exercises)
            VStack {
                HStack {
                    Spacer()
                    if isSelecting {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.primary, Color.accentColor)
                            .opacity(isSelected ? 1 : 0)
                            .overlay {
                                Circle()
                                    .strokeBorder(Color.white.opacity(isSelected ? 1 : 0.3), lineWidth: 2)
                                    
                            }
                    } else {
                        Button {
                            startWorkout(template.exercises, template.name)
                        } label: {
                            Image(systemName: "plus")
                        }
                        .font(.headline)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 4)
                        .foregroundStyle(.primary)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Circle())
                        //.border(Color.red)
                    }
                }
                VStack {
                    Spacer()
                    Text(template.name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.headline)
                    Text("\(template.exercises.count) exercises")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(.subheadline, design: .rounded))
                        .opacity(0.9)
                }
            }
            
            .padding(.all, 14)
        }
        .frame(maxWidth: .infinity, minHeight: 128, maxHeight: 128)

        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(Color.accentColor, lineWidth: 3.5)
            }
        }
            
    }
}

struct NewWorkoutTemplateView : View {
    @State var name: String
    @State var exercises: [WorkoutExercise]
    @State private var isAddingExercises = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showCancellationWarning = false

    var body : some View {
        NavigationStack {
            Form {
                TextField("Template Name", text: $name)
                Section {
                    ForEach(exercises) { exercise in
                        NavigationLink {
                            WorkoutExerciseView(exercise: exercise, active: false, isInTemplate: true)
                        } label: {
                            Text(exercise.exercise.name)
                        }
                    }
                    .onDelete { indexSet in
                        exercises.remove(atOffsets: indexSet)
                    }
                    .onMove { indices, newOffset in
                        exercises.move(fromOffsets: indices, toOffset: newOffset)
                    }
                    Button {
                        isAddingExercises.toggle()
                    } label: {
                        Label("Add Exercises", systemImage: "plus")
                    }
                    .sheet(isPresented: $isAddingExercises) {
                        SelectExercisesView(onDone: { selected in
                            for exercise in selected {
                                exercises.append(WorkoutExercise(exercise: exercise))
                            }
                        })
                    }
                }
            }
            .navigationTitle("New Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        modelContext.insert(WorkoutTemplate(name: name, exercises: exercises))
                        dismiss()
                    } label: {
                        Text("Add")
                    }
                    .fontWeight(.bold)
                    .disabled(name.isEmpty || exercises.isEmpty)
                }
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        if !name.isEmpty || !exercises.isEmpty {
                            showCancellationWarning.toggle()
                        } else {
                            dismiss()
                        }
                    } label: {
                        Text("Cancel")
                    }
                }
            }
            .confirmationDialog("Are you sure you want to discard this template?", isPresented: $showCancellationWarning, titleVisibility: .hidden) {
                Button("Discard Changes", role: .destructive) {
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}
// add reordering templates, should wait for folder tho?
struct WorkoutScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WorkoutTemplate.name) private var templates: [WorkoutTemplate]
    @State private var currentTemplate: WorkoutTemplate?
    @State private var isAddingTemplate = false
    @State private var isSelecting = false
    @State private var selectedTemplates: Set<WorkoutTemplate> = []
    @State private var showDeleteWarning = false
    @State private var showDeleteAlert = false
    @State private var currentlyDeletingTemplate: WorkoutTemplate?
    
    var startWorkout: ([WorkoutExercise], String?) -> Void
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                Button {
                    startWorkout([], nil)
                } label: {
                    HStack {
                        Spacer()
                        Label {
                            Text("Empty Workout")
                        } icon: {
                            Image(systemName: "plus.circle.fill")
                        }
                        .font(.headline)
                        .padding(.all, 8)
                        Spacer()
                    }
                    
                }
                .buttonStyle(.borderedProminent)
                    .padding(.bottom, 8)
                    .disabled(isSelecting)
                    .padding(.horizontal)
                HStack {
                    Text("Templates")
                        .font(.title2.bold())
                        .foregroundStyle(Color.primary)
                        .padding(.vertical, 10)
                    Spacer()
                }
                .padding(.horizontal)
                // 2 column grid with workout templates
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 10) {
                    ForEach(templates) { template in
                        WorkoutTemplateCard(template: template, startWorkout: startWorkout, isSelecting: isSelecting, isSelected: selectedTemplates.contains(template))
                            .onTapGesture {
                                if isSelecting {
                                    if selectedTemplates.contains(template) {
                                        selectedTemplates.remove(template)
                                    } else {
                                        selectedTemplates.insert(template)
                                    }
                                } else {
                                    currentTemplate = template
                                }
                            }
                            .jiggling(isJiggling: isSelecting)
                            .contextMenu {
                                Button("Duplicate", systemImage: "plus.rectangle.on.rectangle") {
                                    modelContext.insert(WorkoutTemplate(name: "\(template.name) Copy", exercises: template.exercises))
                                }
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    currentlyDeletingTemplate = template
                                    showDeleteAlert.toggle()
                                }
                            }
                        
                    }
                }
                .padding(.horizontal)
                
            }
            .alert("Delete Template \"\(currentlyDeletingTemplate?.name ?? "Unnamed" )\"?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let currentlyDeletingTemplate {
                        modelContext.delete(currentlyDeletingTemplate)
                    }
                }
                
            } message: {
                Text("This action cannot be undone.")
            }
            .sheet(item: $currentTemplate) { template in
                NavigationStack {
                    TemplateView(template: template, startWorkout: startWorkout)
                }
            }
            .sheet (isPresented: $isAddingTemplate) {
                NewWorkoutTemplateView(name: "", exercises: [])
            }
            
            .navigationTitle(isSelecting ? (selectedTemplates.isEmpty ? "Select Templates" : " \(selectedTemplates.count) Selected") : "Workout")
            .toolbar {
                if isSelecting {
                    ToolbarItemGroup(placement: .topBarLeading) {
                        if selectedTemplates.isEmpty {
                            Button {
                                for template in templates {
                                    selectedTemplates.insert(template)
                                }
                            } label: {
                                Text("Select All")
                            }
                        } else {
                            Button {
                                selectedTemplates.removeAll()
                            } label: {
                                Text("Deselect All")
                            }
                        }
                        
                    }
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button {
                            isSelecting = false
                            selectedTemplates.removeAll()
                        } label: {
                            Text("Done")
                        }
                        .fontWeight(.bold)
                    }
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button("Duplicate") {
                            for template in selectedTemplates {
                                modelContext.insert(WorkoutTemplate(name: "\(template.name) Copy", exercises: template.exercises))
                            }
                            isSelecting = false
                            selectedTemplates.removeAll()
                        }
                        .disabled(selectedTemplates.isEmpty)
                        Button( "Delete", role: .destructive) {
                            showDeleteWarning = true
                        }
                        .buttonStyle(.borderless)
                        .disabled(selectedTemplates.isEmpty)
                        
                        .confirmationDialog("Delete \(selectedTemplates.count) templates?", isPresented: $showDeleteWarning, titleVisibility: .hidden) {
                            Button("Delete \(selectedTemplates.count) Templates", role: .destructive) {
                                for template in selectedTemplates {
                                    modelContext.delete(template)
                                }
                                selectedTemplates.removeAll()
                                isSelecting = false
                            }
                        } message: {
                            Text("This action cannot be undone.")
                        }
                    }
                } else {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button {
                            isSelecting = true
                        } label: {
                            Text("Select")
                        }
                        Button {
                            isAddingTemplate = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                
            }
        }
    }
    
    
}

#Preview {
    WorkoutScreen(startWorkout: {
        _,_ in
        print("Starting workout")
    })
        .modelContainer(for: WorkoutTemplate.self, inMemory: true) { result in
            do {
                let container = try result.get()
                preloadWorkoutTemplates(container)
            } catch {
                print("Error!")
            }
        }
        
}
