//
//  CalendarView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 24/02/2025.
//
import SwiftUI

struct CalendarView: UIViewRepresentable {
    var workouts: [Workout]
    let interval: DateInterval
    @Binding var dateSelected: DateComponents?
    
    func makeUIView(context: Context) -> UICalendarView {
        let view = UICalendarView()
        view.delegate = context.coordinator
        view.calendar = Calendar.current
        view.availableDateRange = interval
        // Make sure our calendar view adapts nicely to size constraints.
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        let dateSelection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        dateSelection.setSelected(dateSelected, animated: false)
        view.selectionBehavior = dateSelection
        return view
    }
    
    
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self, workouts: workouts)
    }
    
    func updateUIView(_ uiView: UICalendarView, context: Context) {
        // TODO
//        if let changedEvent = eventStore.changedEvent {
//                    uiView.reloadDecorations(forDateComponents: [changedEvent.dateComponents], animated: true)
//                    eventStore.changedEvent = nil
//                }
//
//                if let movedEvent = eventStore.movedEvent {
//                    uiView.reloadDecorations(forDateComponents: [movedEvent.dateComponents], animated: true)
//                    eventStore.movedEvent = nil
//                }

    }
    
    class Coordinator: NSObject, @preconcurrency UICalendarViewDelegate , UICalendarSelectionSingleDateDelegate {
        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            parent.dateSelected = dateComponents
        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate, canSelectDate dateComponents: DateComponents?) -> Bool {
            return true
        }
        
        var parent: CalendarView
        var workouts: [Workout]
        
        init(parent: CalendarView, workouts: [Workout]) {
            self.parent = parent
            self.workouts = workouts
        }
        
        @MainActor
        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            let foundWorkouts = workouts.filter { workout in
                Calendar.current.startOfDay(for: workout.date) == Calendar.current.startOfDay(for: dateComponents.date!)
            }
            if foundWorkouts.isEmpty {
                return nil
            }
            return .image(UIImage(systemName: "circle.fill"), color: .init(Color.accentColor), size: .small)
        }
    }

        

}
    
