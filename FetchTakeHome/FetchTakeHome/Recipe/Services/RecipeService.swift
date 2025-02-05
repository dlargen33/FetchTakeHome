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
    case invalidURL(String)
    case networkError(Error)
}

protocol RecipeServiceConfiguration {
    var recipeListRoute: String { get }
    var imageTimeToLive: Double { get }
    var host: String { get }
}

extension RecipeServiceConfiguration {
    var imageTimeToLive: Double {
        return 60.0
    }
    
    var host: String {
        return "d3jbb8n5wk0qxi.cloudfront.net"
    }
}

struct DefaultRecipeServiceConfiguration: RecipeServiceConfiguration {
    var recipeListRoute: String {
        return "recipes-malformed.json"
    }
}

class RecipeService: APIService {
    private let configuration: RecipeServiceConfiguration
    
    init(configuration: RecipeServiceConfiguration = DefaultRecipeServiceConfiguration() ) {
        self.configuration = configuration
    }
    
    func getRecipes() async throws -> [Recipe] {
        do {
            let session = createSession(host: configuration.host)
            let receipeList: RecipeList = try await session.get(path: configuration.recipeListRoute,
                                                                       parameters: nil)
            return receipeList.recipes
        }
        catch {
            print("🌐 Fetching recipes failed: \(error)")
            throw RecipeServiceError.networkError(error)
        }
    }
    
    func getRecipeImage(recipe: Recipe) async throws -> UIImage {
        if let data = await imageDataFromRepo(receiptID: recipe.uuid),
           let image = UIImage(data: data){
            return image
        }
        
        do {
            guard let components = URLComponents(string: recipe.photoUrlSmall),
                  let host = components.host else {
                throw RecipeServiceError.invalidURL(recipe.photoUrlSmall)
            }
            
            let session = createSession(host: host)
            let imageBytes = try await session.download(path: components.path)
            
            guard let image = UIImage(data: imageBytes) else {
                throw RecipeServiceError.invalidImageData
            }
            
            let imageData = ImageData(referenceId: recipe.uuid,
                                      data: imageBytes,
                                      expire: Date().addingTimeInterval(60 * configuration.imageTimeToLive))
            
            await ImageRepository.shared.addImageData(imageData: imageData)
            return image
        }
        catch {
            print("🌐 Image download failed for \(recipe.photoUrlSmall): \(error)")
            throw RecipeServiceError.networkError(error)
        }
    }
}

extension RecipeService {
    
    //TODO inject ImageRepository
    private func imageDataFromRepo(receiptID: String) async -> Data? {
        guard let imageData = await ImageRepository.shared.getImageData(referenceID: receiptID),
              imageData.expire > Date() else {
            return nil
        }
        return imageData.data
    }
}
