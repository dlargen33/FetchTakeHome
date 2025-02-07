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
        return "recipes.json"
    }
}

protocol RecipeServiceProtocol {
    func getRecipes() async throws -> [Recipe]
    func getRecipeImage(recipe: Recipe) async throws -> Data
}

class RecipeService: RecipeServiceProtocol {
    private var session: AsyncSessionProtocol
    private var imageRepository: ImageRepositoryProtocol
    private let configuration: RecipeServiceConfiguration

    init(configuration: RecipeServiceConfiguration = DefaultRecipeServiceConfiguration()) {
        self.configuration = configuration
        self.session = AsyncSession(
            sessionConfiguration: AsyncSession.SessionConfiguration(scheme: "https",
                                                                    host: configuration.host,
                                                                    headers: nil,
                                                                    timeout: 60,
                                                                    decodingStrategy: .convertFromSnakeCase))
        self.imageRepository = ImageRepository.shared
    }

    init(session: AsyncSessionProtocol,
         imageRepository: ImageRepositoryProtocol,
         configuration: RecipeServiceConfiguration = DefaultRecipeServiceConfiguration()) {
        self.session = session
        self.imageRepository = imageRepository
        self.configuration = configuration
    }
    
    func getRecipes() async throws -> [Recipe] {
        do {
            let receipeList: RecipeList = try await session.get(path: configuration.recipeListRoute,
                                                                parameters: nil,
                                                                dateFormatters: nil)
            return receipeList.recipes
        }
        catch {
            print("🌐 getRecipes recipes failed: \(error)")
            throw RecipeServiceError.networkError(error)
        }
    }
    
    func getRecipeImage(recipe: Recipe) async throws -> Data {
        if let data = await imageDataFromRepo(recipeID: recipe.uuid) {
           return data
        }
        
        do {
            guard let photoUrl = recipe.photoUrlSmall,
                  let components = URLComponents(string: photoUrl),
                  let host = components.host else {
                print("🌐 getRecipeImage: Invalid image url")
                throw RecipeServiceError.invalidURL(recipe.photoUrlSmall ?? "Missing image url")
            }
            
            session.sessionConfiguration.host = host
            let imageBytes = try await session.download(path: components.path,
                                                        parameters: nil,
                                                        progress: nil)
            
            await addImageData(referenceId: recipe.uuid,
                               data: imageBytes)
            return imageBytes
        }
        catch {
            print("🌐 getRecipeImage download failed: \(error)")
            throw RecipeServiceError.networkError(error)
        }
    }
}

extension RecipeService {
    private func imageDataFromRepo(recipeID: String) async -> Data? {
        guard let imageData = await imageRepository.getImageData(referenceID: recipeID),
              imageData.expire > Date() else {
            return nil
        }
        return imageData.data
    }
    
    private func addImageData(referenceId: String,
                              data: Data) async {
        let imageData = ImageData(referenceId: referenceId,
                                  data: data,
                                  expire: Date().addingTimeInterval(60 * configuration.imageTimeToLive))
        
        await imageRepository.addImageData(imageData: imageData)
    }
}
