//
//  Recipe.swift
//  FetchTakeHome
//
//  Created by Donald Largen on 1/30/25.
//

import Foundation

struct RecipeList: Codable {
    let recipes: [Recipe]
}

// MARK: - Recipe
struct Recipe: Codable, Identifiable, Hashable {
    let cuisine: String
    let name: String
    let photoUrlLarge: String?
    let photoUrlSmall: String?
    let sourceUrl: String?
    let uuid: String
    let youtubeUrl: String?
    
    var id: String {
        return uuid
    }
}

extension Recipe {
    var hasImageUrl: Bool {
        return photoUrlSmall != nil 
    }
}
