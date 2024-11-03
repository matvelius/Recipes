//
//  NetworkServiceTests.swift
//  RecipeAppTests
//
//  Created by Matvey Kostukovsky on 10/29/24.
//

import XCTest
@testable import RecipeApp

final class NetworkServiceTests: XCTestCase {
    var sut: NetworkService!
    var mockURLSession: URLSession!

    override func setUp() {
        super.setUp()
        mockURLSession = URLSession(configuration: .ephemeral)
        sut = NetworkService(urlSession: mockURLSession)
    }

    func testRetrieveImage_givenEmptyString_throwsError() async {
        await XCTAssertThrowsErrorAsync(try await sut.retrieveImage(using: ""))
    }
    
    func testFetchData_givenEmptyString_throwsError() async {
        do {
            let _: Response = try await sut.fetchData(for: "")
            XCTFail("should throw error")
        } catch {
            // test should pass
        }
    }
}
