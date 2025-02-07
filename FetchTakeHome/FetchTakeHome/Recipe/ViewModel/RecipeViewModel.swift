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
    
    @Published var imageDownloadState: ImageDownloadState = .downloading
    @Published var imageData: Data?
    
    private var image: UIImage?
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
    
    var recipeImage: UIImage {
        if let cached = image {
            return cached
        }
        
        guard let data = imageData,
              let decodedImage = UIImage(data: data) else {
            let missing = UIImage(named: "missing") ?? UIImage()
            image = missing
            return missing
        }
        
        image = decodedImage
        return decodedImage
    }
 
    
    func loadImage() async {
        imageDownloadState = .downloading
        
        // RecipeService will handle this but what is the point of making the call if url is missing
        guard recipe.hasImageUrl else {
            imageData = nil
            imageDownloadState = .complete
            return
        }
        
        do {
            let recipeService = RecipeService()
            imageData = try await recipeService.getRecipeImage(recipe: recipe)
            imageDownloadState = .complete
        }
        catch {
            imageData = nil
        }
    }
}
