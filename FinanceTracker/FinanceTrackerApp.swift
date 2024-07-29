//
//  FinanceTrackerApp.swift
//  FinanceTracker
//
//  Created by Egor Tolmachev on 29.07.2024.
//

import SwiftUI

@main
struct FinanceTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
