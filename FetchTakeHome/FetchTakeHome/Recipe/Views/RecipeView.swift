//
//  RecipeView.swift
//  FetchTakeHome
//
//  Created by Donald Largen on 2/4/25.
//

import SwiftUI

struct RecipeView : View {
    @StateObject private var viewModel: RecipeViewModel
    let action: () -> Void
    
    init(recipe: Recipe, action: @escaping () -> Void ) {
        _viewModel = StateObject(wrappedValue: RecipeViewModel(recipe: recipe))
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                RecipeImageView(viewModel: viewModel)
                RecipeInfoView(recipeName: viewModel.name,
                              cuisine: viewModel.cuisine)
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 3)
        }
        .task {
            await viewModel.loadImage()
        }
    }
}

struct RecipeInfoView: View {
    let recipeName: String
    let cuisine: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(recipeName)
                .font(.headline)
                .foregroundStyle(.black)
            Text(cuisine)
                .font(.subheadline)
                .foregroundStyle(.black)
        }
    }
}

struct RecipeImageView: View {
    @ObservedObject var viewModel: RecipeViewModel
    
    var body: some View {
        ZStack {
            switch viewModel.imageDownloadState {
            case .downloading:
                ZStack {
                    Rectangle()
                        .fill(Color("BackgroundColor"))
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.75)
                        .tint(.white)
                        .foregroundColor(.white)
                }
                .transition(.opacity)
                
            case .complete:
                Image(uiImage: viewModel.recipeImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 2)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 1.0), value: viewModel.imageDownloadState)
    }
}

#Preview {
    let recipe = Recipe(cuisine: "Malaysian",
                        name: "Apam Balik",
                        photoUrlLarge:"https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg",
                        photoUrlSmall: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg",
                        sourceUrl: "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ",
                        uuid: "0c6ca6e7-e32a-4053-b824-1dbf749910d8",
                        youtubeUrl:  "https://www.youtube.com/watch?v=6R8ffRRJcrg")
    
    RecipeView(recipe: recipe) {}
}
