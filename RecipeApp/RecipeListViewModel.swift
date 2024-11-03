//
//  RecipeListViewModel.swift
//  RecipeApp
//
//  Created by Matvey Kostukovsky on 10/31/24.
//

import Foundation
import os

@Observable @MainActor
final public class RecipeListViewModel {
    private let networkService: any NetworkServiceProtocol
    private let logger = Logger(subsystem: "RecipeListViewModel", category: "data")
    
    var recipes = [Recipe]()
    var isLoading = false
    var hasError = false
    
    init(networkService: any NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    func fetchRecipes() async {
        do {
            hasError = false
            isLoading = true
            let response: Response = try await networkService.fetchData(for: Constants.recipesEndpoint)
            recipes = response.recipes.sorted(by: { $0.cuisine < $1.cuisine })
            isLoading = false
            hasError = false
        } catch {
            logger.error("Unable to fetch recipes: \(error)")
            isLoading = false
            hasError = true
        }
    }
    
    struct Constants {
        static let recipesEndpoint = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json"
        static let recipesMalformedDataEndpoint = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-malformed.json"
        static let recipesEmptyListEndpoint = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-empty.json"
    }
}
