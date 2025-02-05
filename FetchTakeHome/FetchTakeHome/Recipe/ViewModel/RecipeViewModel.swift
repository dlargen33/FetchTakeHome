//
//  RecipeViewModel.swift
//  FetchTakeHome
//
//  Created by Donald Largen on 2/4/25.
//

import Foundation
import UIKit

@MainActor
class RecipeViewModel: ObservableObject {
    
    enum ImageDownloadState {
        case downloading
        case complete
        case failed
    }
    
    @Published var recipeImage: UIImage = UIImage() //maybe find some default
    @Published var imageDownloadState: ImageDownloadState = .downloading
    
    private let recipe: Recipe
    
    init(recipe: Recipe) {
        self.recipe = recipe
    }
    
    var name: String {
        recipe.name
    }
    
    var cuisine: String {
        recipe.cuisine
    }
    
    func loadImage() async {
        do {
            imageDownloadState = .downloading
            let recipeService = RecipeService()
            recipeImage = try await recipeService.getRecipeImage(recipe: recipe)
            imageDownloadState = .complete
        }
        catch {
            imageDownloadState = .failed
        }
    }
}
