//
//  ContentView.swift
//  RecipeApp
//
//  Created by Matvey Kostukovsky on 10/31/24.
//

import SwiftUI

@MainActor
struct RecipeListView: View {
    @State private var viewModel = RecipeListViewModel()
    @State private var orientation = UIDeviceOrientation.portrait
        
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if viewModel.isLoading {
                    loadingView()
                } else if viewModel.hasError {
                    errorView()
                } else if viewModel.recipes.isEmpty {
                    emptyView()
                } else {
                    recipeList(with: geometry)
                }
                
                if !viewModel.isLoading {
                    refreshButton()
                }
            }
            .onRotate { newOrientation in
                orientation = newOrientation
            }
        }
        .task {
            await viewModel.fetchRecipes()
        }
        .refreshable {
            await viewModel.fetchRecipes()
        }
    }
    
    @ViewBuilder
    func loadingView() -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ProgressView()
                    .frame(width: 80, height: 80)
                Spacer()
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    func errorView() -> some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                VStack {
                    Text("Unable to load recipes")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .padding()

                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .foregroundColor(.red)
                        .frame(width: 75, height: 65)
                        .padding()
                }
                
                Spacer()
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    func emptyView() -> some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                VStack {
                    Text("No recipes are available. Please try again later or order a pizza.")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .padding()

                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .foregroundColor(.orange)
                        .frame(width: 75, height: 65)
                        .padding()
                }
                
                Spacer()
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder @MainActor
    func recipeList(with geometry: GeometryProxy) -> some View {
        List {
            ForEach(viewModel.recipes, id: \.self.uuid) { recipe in
                    recipeCard(with: recipe, and: geometry)
                        .frame(height: geometry.size.height / (orientation.isLandscape ? 3 : 5))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }
    
    @ViewBuilder @MainActor
    func recipeCard(with recipe: Recipe, and geometry: GeometryProxy) -> some View {
        CachedAsyncImage(key: recipe.uuid, urlString: recipe.photoUrlLarge) { asyncImagePhase in
            VStack {
                switch asyncImagePhase {
                case .success(let image):
                    imageSuccessView(with: image, recipe: recipe, geometry: geometry)
                case .failure(_):
                    imageFailureView()
                case .empty:
                    imageLoadingView()
                @unknown default:
                    imageLoadingView()
                }
            }
            .frame(height: geometry.size.height / (orientation.isLandscape ? 3 : 5))
        }
        .clipShape(RoundedRectangle(cornerRadius: 9))
        .opacity(0.95)
    }
    
    @ViewBuilder
    func imageSuccessView(with image: Image, recipe: Recipe, geometry: GeometryProxy) -> some View {
        ZStack {
            image
                .resizable()
                .scaledToFill()
                .padding(.vertical, 7)
            
            recipeCardLabels(with: recipe, and: geometry)
        }
    }
    
    @ViewBuilder
    func imageFailureView() -> some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                
                Text("Unable to load image")
                    .foregroundStyle(.white)
                    .font(.headline)
                Spacer()
            }
            Spacer()
        }
        .background(Color.red)
    }
    
    @ViewBuilder
    func imageLoadingView() -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            Spacer()
        }
        .background(Color.gray.opacity(0.1))
    }
    
    @ViewBuilder
    func recipeCardLabels(with recipe: Recipe, and geometry: GeometryProxy) -> some View {
        HStack {
            VStack {
                HStack {
                    Text(recipe.name)
                        .font(.headline)
                        .foregroundStyle(Color(UIColor.darkGray))
                        .padding(5)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    Text(recipe.cuisine)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.white)
                        .padding(5)
                        .background(Color(UIColor.darkGray))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Spacer()
                }
            }
            
            Spacer()
        }
        .padding(8)
        .frame(height: geometry.size.height / (orientation.isLandscape ? 3 : 5))
    }
    
    @ViewBuilder
    func refreshButton() -> some View {
        VStack {
            Spacer()
            
            Button {
                Task { await viewModel.fetchRecipes() }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .frame(maxWidth: 220, maxHeight: 45)
                        .foregroundColor(Color.blue)
                    HStack {
                        Text("Refresh")
                            .font(.headline)
                    }
                    .foregroundStyle(Color.white)
                }
            }
            .padding(20)
        }
    }
}

#Preview {
    RecipeListView()
}
