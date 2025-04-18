import SwiftUI
// TODO: start calendar on monday!
struct MiniWorkoutCalendarView: View {
    let workouts: [Workout]
    
    private let currentDate = Date()
    private let calendar = Calendar(identifier: .gregorian) // TODO!
    private var monthStart: Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
    }
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    
    var body: some View {
        VStack() {
            // Calendar grid
            LazyVGrid(columns: columns) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol.prefix(1))
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(Color(.systemGray2))
                        .multilineTextAlignment(.center)
                }
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        VStack {
                            Spacer()
                            Circle()
                                .fill(hasWorkout(on: date) ? Color.accentColor : Color(.systemGray5))
                                .frame(width: 10, height: 10)
                            
                            Spacer()
                        }
                        .frame(height: 16)
                        .background {
                            if calendar.isDateInToday(date) {
                                Circle()
                                    .fill(hasWorkout(on: date) ? Color.accentColor : Color.gray)
                                    .opacity(0.3)
                                    .frame(width: 14, height: 14)
                            }
                                
                        }
                    } else {
                        Color.clear
                            .frame(height: 16)
                    }
                }
            }
        }
    }
    
    private var weekdaySymbols: [String] {
        calendar.shortWeekdaySymbols
    }
    
    private func daysInMonth() -> [Date?] {
        let firstDayOfMonth = monthStart
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1
        
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!.count
        
        var days: [Date?] = []
        for _ in 0..<firstWeekday {
            days.append(nil)
        }
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        let remainingDays = (7 - (days.count % 7)) % 7
        for _ in 0..<remainingDays {
            days.append(nil)
        }
        
        return days
    }
    
    private func hasWorkout(on date: Date) -> Bool {
        // Check if there's a workout on the given date
        return workouts.contains { workout in
            calendar.isDate(workout.date, inSameDayAs: date)
        }
    }
}
