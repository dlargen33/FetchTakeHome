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
    }
    
    @Published var recipeImage: UIImage = UIImage()
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
        imageDownloadState = .downloading
        
        // RecipeService will handle this but what is the point of making the call if url is missing
        guard recipe.hasImageUrl else {
            recipeImage = UIImage(named: "missing") ?? UIImage()
            imageDownloadState = .complete
            return
        }
        
        do {
            let recipeService = RecipeService()
            recipeImage = try await recipeService.getRecipeImage(recipe: recipe)
            imageDownloadState = .complete
        }
        catch {
            recipeImage = UIImage(named: "missing") ?? UIImage()
        }
    }
}
