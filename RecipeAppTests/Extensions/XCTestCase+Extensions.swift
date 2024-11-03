//
//  XCTestCase+Extensions.swift
//  RecipeAppTests
//
//  Created by Matvey Kostukovsky on 11/3/24.
//

import XCTest

extension XCTestCase {
    // borrowed from https://stackoverflow.com/a/77402171/10431460
    func XCTAssertThrowsErrorAsync<T>(_ expression: @autoclosure () async throws -> T) async {
        do {
            _ = try await expression()
            XCTFail("No error was thrown.")
        } catch {
            //Pass
        }
    }
}
