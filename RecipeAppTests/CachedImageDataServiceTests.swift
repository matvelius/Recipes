//
//  CachedImageDataServiceTests.swift
//  RecipeAppTests
//
//  Created by Matvey Kostukovsky on 10/29/24.
//

import Foundation
import XCTest
@testable import RecipeApp

class CachedImageDataServiceTests: XCTestCase {
    var sut: CachedImageDataService!
    
    var mockInMemoryCacheService: InMemoryCacheServiceProtocol!
    var mockFileStorageService: FileStorageServiceProtocol!
    var mockNetworkService: (any NetworkServiceProtocol)?
    
    let testImage = UIImage(systemName: "dog.fill")!
    let testKey = "testKey"
    let testURLString = "https://fetch.com/"
    
    @MainActor
    override func setUp() {
        super.setUp()
        
        let mockCache = NSCache<NSString, NSData>()
        mockInMemoryCacheService = MockInMemoryCacheService(shouldThrow: false, cache: mockCache)
        mockFileStorageService = MockFileStorageService()
        mockNetworkService = MockNetworkService(shouldThrow: false)
        
        sut = CachedImageDataService(inMemoryCacheService: mockInMemoryCacheService,
                                     fileStorageService: mockFileStorageService,
                                     networkService: mockNetworkService!)
    }
    
    override func tearDown() {
        try? mockInMemoryCacheService.removeObject(for: testKey)
        try? mockFileStorageService.removeImage(for: testKey)
    }
    
    func testLoadImage_givenImageInMemory_retrievesImageFromMemory() async {
        guard let data = testImage.pngData() else {
            XCTFail("unable to create a data object")
            return
        }
        
        do {
            try mockInMemoryCacheService.set(object: data, for: testKey)
        } catch {
            XCTFail("unable to set data in memory: \(error.localizedDescription)")
            return
        }
        
        await sut.loadImage(with: testKey, imageURLString: testURLString)
        switch await sut.currentState {
        case .success(image: let uiImage):
            XCTAssertEqual(uiImage.pngData()?.count, testImage.pngData()?.count)
        default:
            XCTFail()
        }
    }
    
    func testLoadImage_givenImageOnDisk_retrievesImageFromDisk() async {
        do {
            try mockFileStorageService.save(testImage, for: testKey)
        } catch {
            XCTFail("unable to save image on disk: \(error.localizedDescription)")
            return
        }
        
        await sut.loadImage(with: testKey, imageURLString: testURLString)
        switch await sut.currentState {
        case .success(image: let uiImage):
            XCTAssertEqual(uiImage.pngData()?.count, testImage.pngData()?.count)
        default:
            XCTFail()
        }
    }
    
    func testLoadImage_givenNoImageInMemoryOrOnDisk_retrievesImageFromNetwork() async {
        await sut.loadImage(with: testKey, imageURLString: testURLString)
        switch await sut.currentState {
        case .success(image: let uiImage):
            XCTAssertEqual(uiImage.pngData()?.count, testImage.pngData()?.count)
            // verify the image was stored in memory and on disk as well
            do {
                let imageFromCache = try mockInMemoryCacheService.retrieveObject(for: testKey)
                let imageFromDisk = try mockFileStorageService.retrieveImage(for: testKey)
                XCTAssertEqual(imageFromCache?.count, uiImage.jpegData(compressionQuality: 1.0)?.count)
                XCTAssertEqual(imageFromDisk?.jpegData(compressionQuality: 1.0)?.count, uiImage.jpegData(compressionQuality: 1.0)?.count)
            } catch {
                XCTFail("unable to verify stored images: \(error.localizedDescription)")
            }
        default:
            XCTFail()
        }
    }
    
    func testLoadImage_whenBadResponseIsReceived_setsCurrentStateToFailed() async {
        mockNetworkService = MockNetworkService(shouldThrow: true)
        sut = await CachedImageDataService(inMemoryCacheService: mockInMemoryCacheService,
                                           fileStorageService: mockFileStorageService,
                                           networkService: mockNetworkService!)
        await sut.loadImage(with: testKey, imageURLString: testURLString)
        switch await sut.currentState {
        case .failed(_):
            // success
            break
        default:
            XCTFail()
        }
    }
}

class MockInMemoryCacheService: InMemoryCacheServiceProtocol {
    let image = UIImage(systemName: "dog.fill")
    
    var shouldThrow: Bool = false
    
    init(shouldThrow: Bool, cache: InMemoryCache) {
        self.shouldThrow = shouldThrow
        self.cache = cache
    }
    
    func set(object: Data, for key: String) throws {
        if shouldThrow { throw InMemoryCacheServiceError.keyIsAnEmptyString }
        cache.setObject(object as NSData, forKey: key as NSString)
    }
    
    func retrieveObject(for key: String) throws -> Data? {
        if shouldThrow { throw InMemoryCacheServiceError.keyIsAnEmptyString }
        return cache.object(forKey: key as NSString) as Data?
    }
    
    var cache: InMemoryCache
    
    func removeObject(for key: String) throws {
        cache.removeObject(forKey: NSString(string: key))
    }
}

class MockFileStorageService: FileStorageServiceProtocol {
    var shouldThrow: Bool = false
    
    internal var folderURL: URL? {
        fileManager
            .urls(for: .cachesDirectory, in: .userDomainMask)
            .first
    }
    
    private let fileManager = FileManager()
    
    func save(_ image: UIImage, for key: String) throws {
        if shouldThrow { throw FileStorageServiceError.keyIsAnEmptyString }
        
        guard let pathURL = folderURL?.appendingPathComponent(key + ".cache") else {
            throw FileStorageServiceError.unableToCreateImagePath
        }
        
        guard let jpgImageData = image.pngData() else {
            throw FileStorageServiceError.unableToCreateImageData
        }
        
        do {
            try jpgImageData.write(to: pathURL, options: [.atomic])
        } catch {
            throw FileStorageServiceError.unableToWriteToDisk(error.localizedDescription)
        }
    }
    
    func retrieveImage(for key: String) throws -> UIImage? {
        if shouldThrow { throw FileStorageServiceError.keyIsAnEmptyString }
        
        guard let pathURL = folderURL?.appendingPathComponent(key + ".cache") else {
            throw FileStorageServiceError.unableToCreateImagePath
        }
        
        guard fileManager.fileExists(atPath: pathURL.path) else {
            return nil
        }
        
        return UIImage(contentsOfFile: pathURL.path)
    }
    
    func removeImage(for key: String) throws {
        guard let pathURL = folderURL?.appendingPathComponent(key + ".cache") else {
            throw FileStorageServiceError.unableToCreateImagePath
        }
        
        guard fileManager.fileExists(atPath: pathURL.path) else {
            return
        }
        
        try fileManager.removeItem(at: pathURL)
    }
}

class MockNetworkService: NetworkServiceProtocol {
    typealias T = Response
    
    var shouldThrow: Bool = false
    
    init(shouldThrow: Bool) {
        self.shouldThrow = shouldThrow
    }
    
    func retrieveImage(using urlString: String) async throws -> UIImage? {
        if shouldThrow { throw NetworkServiceError.badResponse }
        return UIImage(systemName: "dog.fill")
    }
    
    func fetchData<T: Decodable>(for urlString: String) async throws -> T {
        if shouldThrow { throw NetworkServiceError.unableToDecodeData }
        let recipe = Recipe(cuisine: "cuisine", name: "name", photoUrlLarge: "photoUrlLarge", uuid: "uuid")
        return Response(recipes: [recipe]) as! T
    }
}


