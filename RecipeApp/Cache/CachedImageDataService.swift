//
//  CachedImageDataService.swift
//  RecipeApp
//
//  Created by Matvey Kostukovsky on 10/29/24.
//

import UIKit
import os

@MainActor
protocol CachedImageDataServiceProtocol {
    var currentState: CachedImageCurrentState? { get set }
    func loadImage(with key: String, imageURLString: String) async
}

@Observable @MainActor
public final class CachedImageDataService {
    private(set) var currentState: CachedImageCurrentState? = nil
    
    private let inMemoryCacheService: InMemoryCacheServiceProtocol
    private let fileStorageService: FileStorageServiceProtocol
    private let networkService: any NetworkServiceProtocol
    
    private let logger = Logger(subsystem: "CachedImageDataService", category: "data")
    
    init(inMemoryCacheService: InMemoryCacheServiceProtocol = InMemoryCacheService.shared,
         fileStorageService: FileStorageServiceProtocol = FileStorageService.shared,
         networkService: any NetworkServiceProtocol = NetworkService.shared) {
        self.inMemoryCacheService = inMemoryCacheService
        self.fileStorageService = fileStorageService
        self.networkService = networkService
    }
    
    @MainActor
    func loadImage(with key: String, imageURLString: String) async {
        // first try the in-memory cache
        do {
            if let data = try inMemoryCacheService.retrieveObject(for: key),
               let uiImage = UIImage(data: data) {
                currentState = .success(image: uiImage)
                logger.info("Successfully loaded image for key \(key) from in-memory cache")
                return
            }
        } catch {
            logger.error("Error loading image from in-memory cache: \(error.localizedDescription)")
        }

        // then try file storage
        do {
            if let uiImage = try fileStorageService.retrieveImage(for: key) {
                currentState = .success(image: uiImage)
                logger.info("Successfully loaded image for key \(key) from file storage")
                
                if let data = uiImage.jpegData(compressionQuality: 1.0) {
                    try? inMemoryCacheService.set(object: data, for: key)
                }
                
                return
            }
        } catch {
            logger.error("Error loading image from file storage: \(error.localizedDescription)")
        }
        
        // otherwise load from network
        self.currentState = .loading
        
        do {
            if let uiImage = try await networkService.retrieveImage(using: imageURLString) {
                currentState = .success(image: uiImage)
                logger.info("Successfully loaded image for key \(key) from network")
                
                if let data = uiImage.jpegData(compressionQuality: 1.0) {
                    try? inMemoryCacheService.set(object: data, for: key)
                }
                try? fileStorageService.save(uiImage, for: key)
                
                return
            }
        } catch {
            currentState = .failed(error: error)
            logger.error("Error loading image \(key) from network: \(error.localizedDescription)")
        }
    }
}

enum CachedImageCurrentState: Equatable {
    case loading
    case failed(error: Error)
    case success(image: UIImage)
    
    // Conforming to Equatable requires that the associated types
    // are Equatable, which is not the case for Error
    // https://stackoverflow.com/a/76417617/10431460
    var reflectedValue: String { String(reflecting: self) }
    
    static func == (lhs: CachedImageCurrentState, rhs: CachedImageCurrentState) -> Bool {
        lhs.reflectedValue == rhs.reflectedValue
    }
}

