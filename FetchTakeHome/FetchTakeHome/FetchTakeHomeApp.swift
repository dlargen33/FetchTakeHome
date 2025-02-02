//
//  FetchTakeHomeApp.swift
//  FetchTakeHome
//
//  Created by Donald Largen on 1/28/25.
//

import SwiftUI

@main
struct FetchTakeHomeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
