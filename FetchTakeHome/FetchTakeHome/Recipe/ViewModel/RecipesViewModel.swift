//
//  RecipesViewModel.swift
//  FetchTakeHome
//
//  Created by Donald Largen on 2/4/25.
//

import Foundation
import Combine

@MainActor
class RecipesViewModel: ObservableObject {
    enum LoadingState {
        case completed
        case loading
        case error
        case emptyData
    }
    
    @Published var recipes = [Recipe]()
    @Published var loadingState = LoadingState.loading
    @Published var showAlert = false
    @Published var lastErrorMessage: String = ""
    
    func getRecipes() async {
        self.recipes = []
        self.loadingState = .loading
        
        ///
        /// Huge hack. Need to add a delay do to the call recipeService.getRecipes().
        /// The api request happens very quickly.
        /// SwiftUI batches up updates and state on the view was not being updated as I wanted.
        /// Probably could live with out it.
        ///
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        do {
            let recipeService = RecipeService()
            self.recipes = try await recipeService.getRecipes()
            self.loadingState = self.recipes.count > 0 ? .completed : .emptyData
        }
        catch {
            print("Failed to get recipe list")
            self.loadingState = .error
            self.showAlert = true
            self.lastErrorMessage = error.localizedDescription
        }
    }
}
