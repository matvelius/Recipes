//
//  RecipeListViewModelTests.swift
//  RecipeAppTests
//
//  Created by Matvey Kostukovsky on 11/3/24.
//

import Foundation
import XCTest
@testable import RecipeApp

class RecipeListViewModelTests: XCTestCase {
    var sut: RecipeListViewModel!

    var mockNetworkService: (any NetworkServiceProtocol)?
    
    @MainActor
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService(shouldThrow: false)
        sut = RecipeListViewModel(networkService: mockNetworkService!)
    }
    
    @MainActor
    func testFetchRecipes_whenResponseIsReceived_recipesAreSet() async {
        await sut.fetchRecipes()
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(sut.hasError)
        XCTAssertFalse(sut.recipes.isEmpty)
    }
    
    @MainActor
    func testFetchRecipes_whenNetworkServiceThrowsError_hasErrorIsSetCorrectly() async {
        mockNetworkService = MockNetworkService(shouldThrow: true)
        sut = RecipeListViewModel(networkService: mockNetworkService!)
        await sut.fetchRecipes()
        XCTAssertTrue(sut.recipes.isEmpty)
        XCTAssertTrue(sut.hasError)
        XCTAssertFalse(sut.isLoading)
    }
}
