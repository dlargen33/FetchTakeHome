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
struct Recipe: Codable {
    let cuisine: String
    let name: String
    let photoUrlLarge: String
    let photoUrlSmall: String
    let sourceURL: String?
    let uuid: String
    let youtubeURL: String?
}
