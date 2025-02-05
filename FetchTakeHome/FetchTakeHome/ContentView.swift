//
//  ContentView.swift
//  FetchTakeHome
//
//  Created by Donald Largen on 1/28/25.
//

import SwiftUI
import CoreData

enum Page: Identifiable, Hashable {
    case recipeDetails(URL)
    
    var id: String {
        switch self {
        case .recipeDetails(_): "recipeDetails"
        }
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var path = NavigationPath()
      
    init() {
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
            
        let appearance = UINavigationBarAppearance()
        
        let backItemAppearance = UIBarButtonItemAppearance()
        backItemAppearance.normal.titleTextAttributes = [.foregroundColor : UIColor.white]
        appearance.backButtonAppearance = backItemAppearance
        
        let image = UIImage(systemName: "chevron.backward")?.withTintColor(.white,
                                                                           renderingMode: .alwaysOriginal)
        appearance.setBackIndicatorImage(image, transitionMaskImage: image)
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "BackgroundColor")
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    var body: some View {
        NavigationStack(path: $path){
                recipeListView()
                .navigationDestination(for: Page.self) { page in
                    if case .recipeDetails(let url) = page {
                        RecipeDetailView(url: url)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func recipeListView() -> RecipeListView {
        RecipeListView() { url in
            path.append(Page.recipeDetails(url))
        }
    }
}

   
#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
