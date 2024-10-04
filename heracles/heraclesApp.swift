//
//  heraclesApp.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 04/10/2024.
//

import SwiftUI
import SwiftData

@main
struct heraclesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Workout.self)
        }
    }
}
