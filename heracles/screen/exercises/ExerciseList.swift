//
//  ExerciseList.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 26/02/2025.
//

import SwiftUI
import UIKit
import SwiftData
import Observation

// Wrapper for UITableView in SwiftUI
struct TableViewWrapper<Content: View, T>: UIViewControllerRepresentable {
    var data: TableViewData<T> // Observable class
    var onSelect: ((T) -> Void)? = nil
    var isSelected: ((T) -> Bool)? = nil
    @ViewBuilder let content: (T) -> Content
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UITableViewController {
        let tableViewController = UITableViewController()
        tableViewController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableViewController.tableView.delegate = context.coordinator
        tableViewController.tableView.dataSource = context.coordinator
        tableViewController.tableView.allowsMultipleSelection = onSelect != nil
        return tableViewController
    }
    
    
    func updateUIViewController(_ uiViewController: UITableViewController, context: Context) {
        uiViewController.tableView.reloadData()
    }
    
    class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {
        var parent: TableViewWrapper
        
        init(_ parent: TableViewWrapper) {
            self.parent = parent
        }
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return parent.data.sections.count
        }
        
        func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return parent.data.sections[section].title
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return parent.data.sections[section].items.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            let item = parent.data.sections[indexPath.section].items[indexPath.row]
            cell.contentConfiguration = UIHostingConfiguration(content: {
                parent.content(item)
            })
            if let isSelected = parent.isSelected {
                cell.isSelected = isSelected(item)
            }
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if let onSelect = parent.onSelect {
                onSelect(parent.data.sections[indexPath.section].items[indexPath.row])
            }
        }
        
        func sectionIndexTitles(for tableView: UITableView) -> [String]? {
            let titles = parent.data.sections.map { $0.title }
            if titles.allSatisfy({$0.count == 1}) && !titles.isEmpty {
                return titles
            }
            return nil
        }
    }
}

// ObservableObject to trigger updates
@Observable
class TableViewData<T> {
    var sections: [(title: String, items: [T])]
    
    init(sections: [(title: String, items: [T])] = []) {
        self.sections = sections
    }
}

// TODO: add filtering by primary muscle group

struct ExerciseFilterSheet : View {
    @Binding var selectedEquipment: Set<Equipment>
    @Binding var selectedMuscles: Set<Muscle>
    
    @Environment(\.dismiss) var dismiss
    
    @State private var editMode: EditMode = .active
    
    var body: some View {
        NavigationStack {
            List(selection: $selectedEquipment) {
                Section("Equipment") {
                    ForEach(Equipment.allCases, id: \.self) { equipment in
                        Text(equipment.displayName())
                    }
                }
            }
            .toolbar {
                Button("Done") {
                    dismiss()
                }
            }.environment(\.editMode, $editMode)
            
        }
        
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

struct ExerciseList: View {
    var selectedGroup: MuscleGroup?
    var recents: Bool = false
    var customs: Bool = false
    var exercises: [Exercise]
    var workouts: [Workout] // optimize in future!
    @State var searchText = ""
    @State private var tableData = TableViewData<Exercise>() // Holds table data
    @State private var selectedEquipment: Set<Equipment> = .init( Equipment.allCases)
    
    @State private var selectedMuscles: Set<Muscle> = .init(Muscle.allCases)
    @State private var showFilters = false
    
    @State private var showNewExercise = false
    
    var body: some View {
        Group {
            if exercises.isEmpty {
                ProgressView()
            } else {
                TableViewWrapper(data: tableData) { item in
                    NavigationLink {
                        ExerciseView(exercise: item)
                    } label: {
                        HStack {
                            Text(item.name)
                                .foregroundStyle(Color.primary)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Image(systemName: "chevron.forward")
                                .foregroundStyle(Color(UIColor.tertiaryLabel))
                                .imageScale(.small)
                        }
                        .padding(.vertical, 5)
                        
                    }
                    
                }
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                .edgesIgnoringSafeArea(.all)
                .onAppear { updateGroupedExercises() }
                .onChange(of: exercises) {updateGroupedExercises() }
                .onChange(of: searchText) { updateGroupedExercises() }
                .onChange(of: selectedEquipment) {updateGroupedExercises() }
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button {
                            showFilters.toggle()
                        } label: {
                            Label("filters", systemImage: "line.3.horizontal.decrease.circle")
                        }
                        .labelStyle(.iconOnly)
                        if !recents {
                            Button {
                                showNewExercise.toggle()
                            } label: {
                                Label("Create Exercise", systemImage: "plus")
                            }
                        }

                    }
                }
                .sheet(isPresented: $showFilters) {
                    ExerciseFilterSheet(selectedEquipment: $selectedEquipment, selectedMuscles: $selectedMuscles)
                }
                .sheet(isPresented: $showNewExercise) {
                    NewExerciseView()
                }
                .overlay {
                    if tableData.sections.first == nil || tableData.sections.first!.items.isEmpty {
                        if recents {
                            ContentUnavailableView {
                                Label("No Recent Exercises", systemImage: "archivebox")
                            } description: {
                                Text("Exercises you recently used will appear here.")
                            }
                        }
                        
                        if customs {
                            ContentUnavailableView {
                                Label("No Custom Exercises", systemImage: "archivebox")
                            } description: {
                                Text("Exercises you create will appear here.")
                            } actions: {
                                Button("Create Exercise") {
                                    showNewExercise.toggle()
                                }
                                .buttonStyle(.borderless)
                                
                            }
                        }
                    }
                }
            }
        }
    }
    // TODO: possibly optimize this function futher
    private func updateGroupedExercises() {
        // Use a single pass approach for filtering
        let filtered = exercises.filter { exercise in
            // Combine all filter conditions with short-circuit evaluation
            (searchText.isEmpty || exercise.name.localizedCaseInsensitiveContains(searchText.trimmingCharacters(in: .whitespacesAndNewlines))) &&
            (selectedEquipment.contains(where: { equipment in
                exercise.equipment.isEmpty || exercise.equipment.contains(equipment)
            })) &&
            (recents ? false : // Skip this filter for recents
                customs ? exercise.custom : // Only custom exercises
                selectedGroup == nil || exercise.primaryMuscles.contains(where: { muscle in muscle_to_group[muscle] == selectedGroup }))
        }
        
        if recents {
            // Process recents with better performance
            let recentExercises = workouts
                .sorted(by: { $0.date > $1.date }) // Reverse sort to get latest first
                .prefix(50) // Limit initial processing to recent workouts
                .flatMap { $0.exercises }
                .map { $0.exercise }
            
            // Use a set for faster duplicate elimination
            var uniqueExercises = Set<Exercise>()
            let recentFiltered = recentExercises.filter { exercise in
                // Add to set and check if it was already there
                let isNew = uniqueExercises.insert(exercise).inserted
                // Only keep new items that also match other filters
                return isNew &&
                       (searchText.isEmpty || exercise.name.localizedCaseInsensitiveContains(searchText)) &&
                       selectedEquipment.contains(where: { equipment in
                           exercise.equipment.contains(equipment)
                       })
            }
            
            tableData.sections = [("", recentFiltered)]
            return
        }

        // Early exit if nothing to display
        if filtered.isEmpty {
            tableData.sections = []
            return
        }
        
        // Use Dictionary(grouping:) just once and sort the result
        let sorted = filtered
            .sorted { $0.name < $1.name }
        
        // Only create sections if we have results
        if !sorted.isEmpty {
            // Create dictionary in one pass with first letter as key
            var dict = [String: [Exercise]]()
            for exercise in sorted {
                let key = String(exercise.name.prefix(1).uppercased())
                dict[key, default: []].append(exercise)
            }
            
            // Convert to section format
            tableData.sections = dict.sorted { $0.key < $1.key }
                .map { (title: $0.key, items: $0.value) }
        } else {
            tableData.sections = []
        }
    }

}


#Preview {
    NavigationStack {
        ExerciseList(exercises: [], workouts: [])
            .modelContainer(for: Exercise.self, inMemory: true) { result in
                do {
                    let container = try result.get()
                    preloadExercises(container)
                } catch {
                    print("Failed to create model container.")
                }
            }
    }
}
