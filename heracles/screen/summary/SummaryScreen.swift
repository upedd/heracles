//
//  SummaryScreen.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 13/02/2025.
//

import SwiftUI
import SwiftData
import Charts
// BIG TODO: customization!!!
// possible ideas
// workout heatmap or workouts per week
// total time, reps, weight,
// mini graphs for different exercises
// possibly per muscle group or just muscle?


struct SummaryCard<T: View> : View {
    var title: String
    @ViewBuilder var content: () -> T
    
    var body : some View {
        VStack {
            HStack {
                Text(title)
                
                    .font(.headline)
                
                Spacer()
                //                Image(systemName: "chevron.right")
                //                    .foregroundStyle(Color.accentColor)
            }
            Divider().padding(.horizontal, -12)
            content()
        }
        .padding(.top, 12)
        .padding(.bottom, 12)
        .padding(.horizontal, 12)
        .background(LinearGradient(colors: [Color(.systemGray6).mix(with: Color.white, by: 0.03), Color(.systemGray6)], startPoint: .topTrailing, endPoint: .bottomLeading))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// inspired by: https://www.artemnovichkov.com/blog/github-contribution-graph-swift-charts
struct WorkoutActivityHeatmap : View {
    var workouts: [Workout]
    
    struct HeatMapData : Identifiable {
        var date: Date
        var count: Int
        var weekInMonth: Int
        var id: Date { date }
    }
    
    
    var data: [HeatMapData] {
        let calendar = Calendar.current
        let currentDate = Date()
        
        // Calculate date one year ago from today
        guard let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: currentDate) else {
            return []
        }
        
        // Create an array to hold our chart data
        var chartData: [HeatMapData] = []
        
        // Start with the week that contains the date from one year ago
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: oneYearAgo)
        components.weekday = calendar.firstWeekday // Start of week based on locale
        
        guard var weekStartDate = calendar.date(from: components) else {
            return []
        }
        
        var currentWeekInMonth = 0
        
        // Process each week from one year ago to current date
        while weekStartDate <= currentDate {
            // Get week end date
            guard let weekEndDate = calendar.date(byAdding: .day, value: 6, to: weekStartDate) else {
                continue
            }
            
            // Count workouts in this week
            let workoutsThisWeek = workouts.filter { workout in
                let workoutDate = workout.date
                return workoutDate >= weekStartDate && workoutDate <= weekEndDate
            }
            
            // Add to chart data
            chartData.append(HeatMapData(
                date: weekStartDate,
                count: workoutsThisWeek.count,
                weekInMonth: currentWeekInMonth
            ))
            
            // Move to next week
            guard let nextWeekStartDate = calendar.date(byAdding: .weekOfYear, value: 1, to: weekStartDate) else {
                break
            }
            
            // check if nextWeekStartdate is in the same month
            let nextWeekComponents = calendar.dateComponents([.month], from: nextWeekStartDate)
            let currentMonthComponents = calendar.dateComponents([.month], from: weekStartDate)
            if nextWeekComponents.month != currentMonthComponents.month {
                currentWeekInMonth = 0
            } else {
                currentWeekInMonth += 1
            }
            
            weekStartDate = nextWeekStartDate
        }
        
        return chartData
    }
    
    
    
    var body : some View {
        Chart(data) {
            RectangleMark(
                xStart: .value("Start week", $0.date, unit: .month),
                xEnd: .value("End week", $0.date, unit: .month),
                yStart: .value("Start weekday",$0.weekInMonth),
                yEnd: .value("End weekday", $0.weekInMonth + 1)
            )
            .foregroundStyle(by: .value("Count", $0.count))
            .clipShape(RoundedRectangle(cornerRadius: 4).inset(by: 2))
        }
        .frame(height: 180)
        .chartForegroundStyleScale(domain: 0...10, range: Gradient(colors: colors))
        .chartXAxis {
            AxisMarks(position: .top, values: .stride(by: .month)) {
                AxisValueLabel(format: .dateTime.month())
                    .foregroundStyle(Color.primary)
            }
        }
        .chartYAxis(.hidden)
        .chartYScale(domain: .automatic(includesZero: false, reversed: true))
        .chartLegend {
            HStack(spacing: 4) {
                Text("Less")
                ForEach(legendColors, id: \.self) { color in
                    color
                        .frame(width: 10, height: 10)
                        .cornerRadius(2)
                }
                Text("More")
            }
            .padding(4)
            .foregroundStyle(Color.primary)
            .font(.caption2)
        }
    }
    private var colors: [Color] {
        (0...10).map { index in
            if index == 0 {
                return Color(.systemGray5)
            }
            return Color.accentColor.opacity(Double(index) / 10)
        }
    }
    
    private var legendColors: [Color] {
        Array(stride(from: 0, to: colors.count, by: 2).map { colors[$0] })
    }
}

struct MuscleGroupData : Identifiable {
    var name: String
    var volume: Double
    var id: String { name }
}
// TODO: combine small sectors into one "other category
struct MuscleGroupsPieChart : View {
    var workouts: [Workout]
    
    // TODO! better way to do this
    var data: [MuscleGroupData] {
        var muscleGroups: [String: Double] = [:]
        
        for workout in workouts {
            if workout.date < Date.now.startOfWeek || workout.date > Date.now.startOfWeek.addingTimeInterval(60 * 60 * 24 * 7) {
                continue
            }
            for exercise in workout.exercises {
                if !exercise.exercise.trackReps || !exercise.exercise.trackWeight {
                    continue
                }
                let muscleGroup = exercise.exercise.primaryMuscles
                
                var volume = exercise.sets.reduce(0) { $0 + ($1.weight ?? 0) * Double($1.reps!) }
                
                volume /= Double(muscleGroup.count)
                for group in muscleGroup {
                    let groupName = (muscle_to_group[group]?.rawValue ?? "other").capitalized
                    if let existingVolume = muscleGroups[groupName] {
                        muscleGroups[groupName] = existingVolume + volume
                    } else {
                        muscleGroups[groupName] = volume
                    }
                }
            }
        }
        
        return muscleGroups.map { MuscleGroupData(name: $0.key, volume: $0.value) }
    }
    
    var body: some View {
        if data.isEmpty {
            Text("No Data")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        } else {
            Chart(data) { item in
                SectorMark(
                    angle: .value("Volume", item.volume),
                    innerRadius: .ratio(0.6),
                    angularInset: 2
                )
                .foregroundStyle(by: .value("Muscle Group", item.name))
                .cornerRadius(2)
            }
            .chartLegend(position: .trailing, alignment: .leading, spacing: 4)
            .chartForegroundStyleScale(mapping: { value in
                for group in MuscleGroup.allCases {
                    if group.rawValue.capitalized == value {
                        return muscle_group_colors[group]!
                    }
                }
                return .gray
            })
//            .chartBackground { chartProxy in
//                GeometryReader { geometry in
//                    if let anchor = chartProxy.plotFrame {
//                        let frame = geometry[anchor]
//                        VStack {
//                            Text("Most Trained")
//                                .font(.system(size: 8, weight: .semibold))
//                                .foregroundStyle(.secondary)
//                            Text(data.max { $0.volume < $1.volume }?.name ?? "")
//                                .font(.system(size: 11, weight: .semibold))
//                        }
//                        .position(x: frame.midX, y: frame.midY)
//                    }
//                }
//            }
        }
        
    }
}

struct StatsCompareView : View {
    var workouts: [Workout]
    var thisWeek: Double {
        var total = 0.0
        for workout in workouts {
            if workout.date < Date.now.startOfWeek || workout.date > Date.now.startOfWeek.addingTimeInterval(60 * 60 * 24 * 7) {
                continue
            }
            for exercise in workout.exercises {
                if !exercise.exercise.trackReps || !exercise.exercise.trackWeight { continue }
                var isChest = false
                for muscle in exercise.exercise.primaryMuscles {
                    if muscle == .chest {
                        isChest = true
                    }
                }
                if !isChest {
                    continue
                }
                for set in exercise.sets {
                    total += Double(set.reps!) * set.weight!
                }
            }
        }
        return total
    }
    var lastWeek: Double {
        var total = 0.0
        for workout in workouts {
            if workout.date < Date.now.startOfWeek.addingTimeInterval(-60 * 60 * 24 * 7) || workout.date > Date.now.startOfWeek {
                continue
            }
            for exercise in workout.exercises {
                if !exercise.exercise.trackReps || !exercise.exercise.trackWeight { continue }
                var isChest = false
                for muscle in exercise.exercise.primaryMuscles {
                    if muscle == .chest {
                        isChest = true
                    }
                }
                if !isChest {
                    continue
                }
                for set in exercise.sets {
                    total += Double(set.reps!) * set.weight!
                }
            }
        }
        return total
    }
    // TODO: mess, TODO: some minimal factor should apply here!
    var thisWeekScaleFactor: Double {
        if thisWeek == 0 {
            return 0
        }
        if lastWeek == 0 {
            return 1
        }
        if thisWeek < lastWeek {
            return max(thisWeek / lastWeek, 0.6) // temp
        } else {
            return 1
        }
    }
    
    var lastWeekScaleFactor: Double {
        if lastWeek == 0 {
            return 0
        }
        if thisWeek == 0 {
            return 1
        }
        if lastWeek < thisWeek {
            return max(lastWeek / thisWeek, 0.6) // temp
        } else {
            return 1
        }
    }
    
    @Environment(Settings.self) private var settings
    
    var body : some View {
        if thisWeek == 0 && lastWeek == 0 {
            Text("No Data")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        } else {
            GeometryReader { proxy in
                VStack(alignment: .leading)  {
                    Text("\(thisWeek.rounded().formatted()) \(settings.weightUnit.short())")
                        .frame(alignment: .leading)
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .padding(.bottom, -1)
                    HStack {
                        Text("This Week")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.vertical, 3)
                    }
                    .padding(.leading, thisWeekScaleFactor == 0 ? 0 : 6)
                    .frame(width: proxy.size.width, alignment: .leading)
                    .background(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.accentColor)
                            .frame(width: proxy.size.width * thisWeekScaleFactor, alignment: .leading)
                    }
                    
                    
                    Text("\(lastWeek.rounded().formatted()) \(settings.weightUnit.short())")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .padding(.bottom, -3)
                    HStack {
                        Text("Last Week")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.vertical, 3)
                    }
                    .padding(.horizontal, lastWeekScaleFactor == 0 ? 0 : 6)
                    .frame(width: proxy.size.width, alignment: .leading)
                    .background(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color(.systemGray4))
                            .frame(width: proxy.size.width * lastWeekScaleFactor, alignment: .leading)
                        
                    }
                    
                    .padding(.bottom, 1)
                }
            }
            
            
            .frame(maxWidth: .infinity)
        }
    }
}

extension Date {
    var startOfWeek: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        guard let startOfWeek = calendar.date(from: components) else {
            return self
        }
        
        return startOfWeek
    }
}

struct VolumeMiniChartView : View {
    var workouts: [Workout]
    var data: (Double,[ChartData]) {
        let calendar = Calendar.current
        var dates = [Date]()
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: calendar.startOfDay(for: Date.now.startOfWeek)) {
                dates.append(date)
            }
        }
        dates.reverse()
        
        var totals = [Date:Double]()
        for date in dates {
            totals[date] = 0
        }
        // possibly optimize
        let workoutsDesc = workouts.sorted { $0.date > $1.date }
        
        var currentDateIdx = 0
        var weekTotal = 0.0
        for workout in workoutsDesc {
            while dates[currentDateIdx] > workout.date {
                if currentDateIdx + 1 >= dates.count {
                    break
                }
                currentDateIdx += 1

            }
            
            if workout.date > dates[currentDateIdx] && workout.date < dates.first!.addingTimeInterval(60 * 60 * 24) {
                var total = 0.0
                for exercise in workout.exercises {
                    if !exercise.exercise.trackReps || !exercise.exercise.trackWeight { continue }
                    for set in exercise.sets {
                        total += Double(set.reps ?? 0) * (set.weight ?? 0)
                    }
                }
                totals[dates[currentDateIdx]]! += total
                weekTotal += total
            }
        }
        return (weekTotal, totals.map { ChartData(value: $0.value, date: $0.key) })
    }
    @Environment(Settings.self) private var settings
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("This Week")
                .font(.caption)
            Text("\(data.0.rounded().formatted()) \(settings.weightUnit.short())")
                .font(.system(size: 26, weight: .semibold, design: .rounded))
            
            Chart(data.1) { item in
                BarMark(
                    x: .value("Date", item.date, unit: .day),
                    y: .value("Volume", item.value)
                )
                .foregroundStyle(Color.accentColor)
            }
            .chartYAxis(.hidden)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) {
                    AxisGridLine(stroke: .init(lineWidth: 0.5))
                    AxisValueLabel(format: .dateTime.weekday(.narrow), centered: true)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Color(.systemGray2))
                        
                }
            }
        }
    }
}

struct SettingsView : View {
    
    @Query(sort: \Plate.weight, order: .reverse) private var plates: [Plate]
    @Query(sort: \Barbell.weight, order: .reverse) private var barbells: [Barbell]
    @Query private var workoutSets: [WorkoutSet]
    @State private var showEquipmentResetWarning = false
    @Environment(\.modelContext) private var modelContext
    @Environment(Settings.self) private var settings
    var body: some View {
        NavigationStack {
            List {
                // TODO: more settings
                Section("Equipment") {
                    NavigationLink {
                        BarbellsView(barbells: barbells, selectedBarbell: .constant(nil))
                    } label: {
                        Text("Barbells")
                    }
                    NavigationLink {
                        AvailablePlatesView(plates: plates)
                    } label: {
                        Text("Plates")
                    }
                    Button("Restore Default Equipment", role: .destructive) {
                        showEquipmentResetWarning.toggle()
                    }
                    .alert("Restore Default Equipment?", isPresented: $showEquipmentResetWarning) {
                        Button("Restore", role: .destructive) {
                            // FIXME: handle error
                            try! modelContext.delete(model: Plate.self)
                            try! modelContext.delete(model: Barbell.self)
                            try! modelContext.save()
                            preloadBarbells(modelContext.container, force: true)
                            preloadPlates(modelContext.container, force: true)
                        }
                    } message: {
                        Text("This action will erase irreversibly all your existing equipment data.")
                    }
                }
                Section {
                    @Bindable var settings = settings
                    Picker("Weight", selection: $settings.weightUnit) {
                        ForEach(WeightUnit.allCases, id: \.rawValue) { unit in
                            Text(unit.rawValue.capitalized).tag(unit)
                        }
                    }
                    .onChange(of: settings.weightUnit) { oldValue, newValue in
                        guard oldValue != newValue else { return }
                        for workoutSet in workoutSets {
                            if let weight = workoutSet.weight {
                                workoutSet.weight = roundToNearestMultiple(of: 0.25, value: weight * (newValue == .pounds ? 2.20462 : 0.453592))
                            }
                        }
                    }
                    Picker("Distance", selection: $settings.distanceUnit) {
                        ForEach(DistanceUnit.allCases, id: \.rawValue) { unit in
                            Text(unit.rawValue.capitalized).tag(unit)
                        }
                    }
                    .onChange(of: settings.distanceUnit) { oldValue, newValue in
                        guard oldValue != newValue else { return }
                        for workoutSet in workoutSets {
                            if let distance = workoutSet.distance {
                                workoutSet.distance = roundToNearestMultiple(of: 0.01, value: distance * (newValue == .miles ? 0.621371 : 1.60934))
                            }
                        }
                    }
                } header: {
                  Text("Units")
                } footer: {
                    Text("Changes will automatically convert all logged values")
                }
                Section {
                    NavigationLink("Privacy Policy") {
                        PrivacyPolicyView()
                    }
                    NavigationLink("Terms of Service") {
                        TermsOfServiceView()
                    }
                    #if DEBUG
                    Button("Load Demo Data") {
                        let start = Date.now
                        print("Loading demo")
                        try! modelContext.delete(model: Workout.self)
                        try! modelContext.save()
                        preloadDemoData(modelContext.container)
                        let end = Date.now
                        print("Loaded demo in \(end.timeIntervalSince(start)) seconds")
                    }
                    #endif
                }
                
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SettingsButton: View {
    @State private var showSettings = false
    
    var body: some View {
        Button(action: {
            showSettings.toggle()
        }) {
            Image(systemName: "person.crop.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.accentColor)
                .frame(width: 36, height: 36)
        }
        .padding([.trailing], 20)
        .padding([.top], 5)
        .sheet(isPresented: $showSettings) {
            SettingsView()
                
        }
    }
}

struct TotalsCard : View {
    var workouts: [Workout]
    @Environment(Settings.self) private var settings
    
    var data: (Int, Double, Double) {
        var count = 0
        var volume = 0.0
        var time = 0.0
        for workout in workouts {
            if Calendar.current.isDate(workout.date, equalTo: Date.now, toGranularity: .month) {
                count += 1
                for exercise in workout.exercises {
                    if !exercise.exercise.trackReps || !exercise.exercise.trackWeight { continue }
                    for set in exercise.sets {
                        volume += Double(set.reps!) * set.weight!
                    }
                    
                }
                time += workout.duration
            }
        }
        return (count, volume, time)
    }
    
    
    var body : some View {
        HStack {
            VStack(alignment: .leading){
                Text("Workouts")
                    .font(.subheadline)
                Text("\(data.0)")
                    .font(.system(size: 26, weight: .semibold, design: .rounded))
            }
            Spacer()
            VStack(alignment: .leading) {
                Text("Volume")
                    .font(.subheadline)
                Text("\(data.1.rounded().formatted()) \(settings.weightUnit.short())")
                    .font(.system(size: 26, weight: .semibold, design: .rounded))
            }
            Spacer()
            VStack(alignment: .leading) {
                Text("Time")
                    .font(.subheadline)
                Text("\((data.2 / (60 * 60)).formatted(.number.precision(.fractionLength(0...1)))) hours")
                    .font(.system(size: 26, weight: .semibold, design: .rounded))
            }
        }
        .padding(.top, 5)
    }
}

struct SummaryScreen: View {
    @Query(sort: \Workout.date, order: .reverse) var workouts: [Workout]
    
    var loggedWorkouts: [Workout] {
        workouts.filter { workout in
            !workout.active
        }
    }
    
    var currentMonth: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: Date.now)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false ) {
                
                SummaryCard(title: "\(currentMonth) Statistics") {
                    TotalsCard(workouts: loggedWorkouts)
                }
                .padding(.horizontal)
                .padding(.top)
                HStack {
                    SummaryCard(title: "Total Volume") {
                        VolumeMiniChartView(workouts: loggedWorkouts)
                            .frame(height: 130)
                    }
                    
                    
                    SummaryCard(title: "\(currentMonth) Activity") {
                        VStack {
                            MiniWorkoutCalendarView(workouts: loggedWorkouts)
                        }
                    }
                }
                .padding(.horizontal)
                SummaryCard(title: "Weekly Activity") {
                    WorkoutActivityHeatmap(workouts: loggedWorkouts)
                }
                .padding(.horizontal)
                
                
                HStack {
                    SummaryCard(title: "Week Muscles") {
                        VStack {
                            MuscleGroupsPieChart(workouts: loggedWorkouts)
                        }
                        .frame(height: 130)
                    }
                    
                    SummaryCard(title: "Chest Volume") {
                        StatsCompareView(workouts: loggedWorkouts)
                            .frame(height: 130)
                    }
                }
                .padding(.horizontal)
            }
            .navigationBarLargeTitleItems(trailing: SettingsButton())
            .navigationTitle("Summary")
        }
    }
}

#Preview {
    let exercise = Exercise.sample
    SummaryScreen()
        .modelContainer(for: [Barbell.self, Workout.self, Plate.self], inMemory: true) { result in
        do {
            let container = try result.get()
            preloadPlates(container)
            preloadBarbells(container)
            container.mainContext.insert(exercise)
            for i in 0..<20 {
                let workout = Workout.sample
                workout.date = Date.now.addingTimeInterval(Double(i) * 60 * 60 * 24)
                workout.exercises.first?.exercise = exercise
                workout.exercises.first?.workout = workout
                container.mainContext.insert(workout)
            }
            
        } catch {
            print("Error!")
        }
                
    }
        .environment(Settings())
}
