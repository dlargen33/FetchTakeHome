//
//  RecipesView.swift
//  FetchTakeHome
//
//  Created by Donald Largen on 2/4/25.
//

import SwiftUI

struct RecipesView: View {
    @ObservedObject var viewModel: RecipesViewModel
    var action: (URL) -> ()
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(viewModel.recipes) { recipe in
                    RecipeView(recipe: recipe) {
                        guard let source = recipe.sourceUrl,
                              let sourceURL = URL(string: source) else {
                            return
                        }
                        action(sourceURL)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    RecipesView(viewModel: RecipesViewModel()) { url in }
}
