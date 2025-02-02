//
//  RecipeService.swift
//  FetchTakeHome
//
//  Created by Donald Largen on 1/30/25.
//

import Foundation
import UIKit

enum RecipeServiceError: Error {
    case invalidImageData
    case networkError(Error)
}

class RecipeService: FetchService {
    private let timeToLive: Double = 60
    
    func getRecipes() async throws -> [Recipe] {
        let path = "recipes.json"
        do {
            let receipeList: RecipeList = try await session.get(path: path, parameters: nil)
            return receipeList.recipes
        }
        catch {
            print("🌐 Fetching recipes failed: \(error.localizedDescription)")
            throw RecipeServiceError.networkError(error)
        }
    }
    
    func getRecipeImage(recipe: Recipe) async throws -> UIImage {
        if let data = await imageDataFromRepo(receiptID: recipe.uuid),
           let image = UIImage(data: data){
            return image
        }
        
        do {
            let imageData = try await session.download(path: recipe.photoUrlSmall)
            guard let image = UIImage(data: imageData) else {
                throw RecipeServiceError.invalidImageData
            }
            
            await ImageRepository.shared.addImageData(imageData:
                                                        ImageData(referenceId: recipe.uuid,
                                                                  data: imageData,
                                                                  expire: Date().addingTimeInterval(60 * timeToLive)))
            return image
        }
        catch {
            print("🌐 Image download failed for \(recipe.photoUrlSmall): \(error.localizedDescription)")
            throw RecipeServiceError.networkError(error)
        }
    }
    
    private func imageDataFromRepo(receiptID: String) async -> Data? {
        guard let imageData = await ImageRepository.shared.getImageData(referenceID: receiptID),
              imageData.expire > Date() else {
            return nil
        }
        return imageData.data
    }
}
