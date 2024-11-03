//
//  FileStorageServiceTests.swift
//  RecipeAppTests
//
//  Created by Matvey Kostukovsky on 10/29/24.
//

import XCTest
@testable import RecipeApp

final class FileStorageServiceTests: XCTestCase {
    var sut: FileStorageServiceProtocol!
    
    let testKey = "testKey"
    let emptyTestKey = ""

    override func setUp() {
        super.setUp()
        sut = FileStorageService()
    }
    
    override func tearDown() {
        let fileManager = FileManager.default
        
        guard let folderURL = fileManager
                                .urls(for: .cachesDirectory, in: .userDomainMask)
                                .first else {
            XCTFail("Unable to retrieve folderURL")
            return
        }
        
        
        let fileURL = folderURL.appendingPathComponent(testKey + ".cache")
        
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                try fileManager.removeItem(at: fileURL)
            } catch {
                XCTFail("Unable to remove file at path: \(fileURL.path)")
            }
        }
    }

    func testSave_whenGivenImageAndKey_savesImageToDisk() throws {
        guard let testImage = UIImage(systemName: "dog.fill") else {
            XCTFail("Unable to create test image")
            return
        }
        
        do {
            try sut.save(testImage, for: testKey)
        } catch {
            XCTFail("Unable to save test image: \(error)")
            return
        }
        
        do {
            let image = try sut.retrieveImage(for: testKey)
            XCTAssertNotNil(image, "Test image should not be nil")
        } catch {
            XCTFail("Unable to retrieve test image: \(error)")
        }
    }
    
    func testSave_whenGivenEmptyKey_throwsError() {
        guard let testImage = UIImage(systemName: "dog.fill") else {
            XCTFail("Unable to create test image")
            return
        }
        
        do {
            try sut.save(testImage, for: emptyTestKey)
            XCTFail("Expected error when saving with empty key, but succeeded")
        } catch FileStorageServiceError.keyIsAnEmptyString {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testRetrieveImage_whenGivenEmptyKey_throwsError() {
        do {
            let _ = try sut.retrieveImage(for: emptyTestKey)
            XCTFail("Expected error when attempting to retrieve image with an empty key, but succeeded")
        } catch FileStorageServiceError.keyIsAnEmptyString {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testRetrieveImage_whenImageDoesNotExist_returnsNil() {
        do {
            let image = try sut.retrieveImage(for: testKey)
            XCTAssertNil(image, "Retrieved image should be nil for a non-existent key")
        } catch {
            XCTFail("Encountered an error trying to retrieve image: \(error)")
        }
    }
    
    func testRemoveImage_whenGivenEmptyKey_throwsError() {
        do {
            let _ = try sut.removeImage(for: emptyTestKey)
            XCTFail("Expected error when attempting to remove image with an empty key, but succeeded")
        } catch FileStorageServiceError.keyIsAnEmptyString {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testRemoveImage_whenImageExists_successfullyRemovesIt() {
        guard let testImage = UIImage(systemName: "dog.fill") else {
            XCTFail("Unable to create test image")
            return
        }
        
        do {
            let _ = try sut.save(testImage, for: testKey)
            XCTAssertNotNil(try sut.retrieveImage(for: testKey))
            let _ = try sut.removeImage(for: testKey)
            XCTAssertNil(try sut.retrieveImage(for: testKey))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
