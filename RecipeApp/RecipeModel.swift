//
//  RecipeModel.swift
//  RecipeApp
//
//  Created by Matvey Kostukovsky on 10/29/24.
//

import Foundation

struct Response: Codable {
    let recipes: [Recipe]
}

struct Recipe: Codable {
    let cuisine: String
    let name: String
    let photoUrlLarge: String
    let uuid: String
}
