//
//  ContentView.swift
//  FetchTakeHome
//
//  Created by Donald Largen on 1/28/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        NavigationView {
            
        }
    }
}

   
#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
