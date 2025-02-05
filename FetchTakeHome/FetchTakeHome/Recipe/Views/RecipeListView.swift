//
//  RecipeList.swift
//  FetchTakeHome
//
//  Created by Donald Largen on 2/4/25.
//

import SwiftUI

struct RecipeListView: View {
    @StateObject var viewModel = RecipesViewModel()
    @State var needsLoad = true
    let onRecipePressed: (URL) -> ()
    
    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 12 / 255, green: 26 / 255, blue: 38 / 255),
                    Color(red: 18 / 255, green: 34 / 255, blue: 46 / 255),
                    Color(red: 24 / 255, green: 40 / 255, blue: 54 / 255)]),
                startPoint: .top,
                endPoint: .bottom)
            .ignoresSafeArea()
            
            VStack {
                if viewModel.loadingState == .loading {
                    LoadingView()
                        .padding(.top, 50.0)
                }
                
                ZStack {
                    switch viewModel.loadingState {
                    case .completed:
                        RecipesView(viewModel: viewModel,
                                    action: onRecipePressed)
                        .padding()
                        .transition(.opacity)
                    case .emptyData:
                        EmptyDataView(action: {
                            Task {
                                await viewModel.getRecipes()
                            }
                        })
                            .transition(.opacity)
                    case .error:
                        EmptyView()
                            .transition(.opacity)
                    default:
                        EmptyView()
                            .transition(.opacity)
                    }
                }
                .animation(.easeIn(duration: 0.5), value: viewModel.loadingState)
            }
        }
        .alert("Error",
               isPresented: $viewModel.showAlert,
               actions: {
                    Button("OK", role: .cancel) {}
                }, message: {
                    Text(viewModel.lastErrorMessage)
                })
        .task {
            if needsLoad {
                needsLoad = false
                await viewModel.getRecipes()
            }
        }
        .navigationTitle("Recipes")
       
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    Task {
                        await viewModel.getRecipes()
                    }
                })
                {
                    Image(systemName: "arrow.clockwise")
                        .tint(.white)
                }
            }
        }
    }
}

#Preview {
    let viewModel = RecipesViewModel()
    RecipeListView(viewModel: viewModel) { url in
        print(url)
    }
}

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
                .tint(.white)
                .foregroundColor(.white)
        }
    }
}




