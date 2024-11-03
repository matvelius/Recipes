//
//  InMemoryCacheServiceTests.swift
//  RecipeAppTests
//
//  Created by Matvey Kostukovsky on 10/29/24.
//

import XCTest
@testable import RecipeApp

final class InMemoryCacheServiceTests: XCTestCase {
    var sut: InMemoryCacheServiceProtocol!
    
    let testKey = "testKey"
    let emptyTestKey = ""

    override func setUp() {
        super.setUp()
        sut = InMemoryCacheService()
    }

    func testSet_whenGivenDataAndKey_savesDataToCache() throws {
        guard let testImage = UIImage(systemName: "dog.fill") else {
            XCTFail("Unable to create test image")
            return
        }
        
        guard let data = testImage.jpegData(compressionQuality: 1.0) else {
            XCTFail("Unable to create NSData from test image")
            return
        }
        
        do {
            try sut.set(object: data, for: testKey)
            XCTAssertNotNil(try sut.retrieveObject(for: testKey), "Test data should not be nil")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testSet_whenGivenEmptyKey_throwsError() {
        guard let testImage = UIImage(systemName: "dog.fill") else {
            XCTFail("Unable to create test image")
            return
        }
        
        guard let data = testImage.jpegData(compressionQuality: 1.0) else {
            XCTFail("Unable to create NSData from test image")
            return
        }
        
        do {
            try sut.set(object: data, for: emptyTestKey)
            XCTFail("Expected error when saving with empty key, but succeeded")
        } catch InMemoryCacheServiceError.keyIsAnEmptyString {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testRetrieveObject_whenGivenEmptyKey_throwsError() {
        do {
            let _ = try sut.retrieveObject(for: emptyTestKey)
            XCTFail("Expected error when attempting to retrieve object with an empty key, but succeeded")
        } catch InMemoryCacheServiceError.keyIsAnEmptyString {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testRetrieveObject_whenImageDoesNotExist_returnsNil() {
        do {
            let image = try sut.retrieveObject(for: testKey)
            XCTAssertNil(image, "Retrieved object should be nil for a non-existent key")
        } catch {
            XCTFail("Encountered an error trying to retrieve object: \(error)")
        }
    }
    
    func testRemoveObject_whenGivenEmptyKey_throwsError() {
        do {
            let _ = try sut.removeObject(for: emptyTestKey)
            XCTFail("Expected error when attempting to remove object with an empty key, but succeeded")
        } catch InMemoryCacheServiceError.keyIsAnEmptyString {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testRemoveObject_whenObjectExists_successfullyRemovesObject() {
        let testObject = Data()
        do {
            try sut.set(object: testObject, for: testKey)
            XCTAssertNotNil(try sut.retrieveObject(for: testKey))
            let _ = try sut.removeObject(for: testKey)
            XCTAssertNil(try sut.retrieveObject(for: testKey))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
