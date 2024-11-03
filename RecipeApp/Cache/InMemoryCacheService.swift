//
//  InMemoryCacheService.swift
//  RecipeApp
//
//  Created by Matvey Kostukovsky on 10/29/24.
//

import Foundation

protocol InMemoryCacheServiceProtocol {
    typealias InMemoryCache = NSCache<NSString, NSData>
    var cache: InMemoryCache { get set }
    
    func set(object: Data, for key: String) throws
    func retrieveObject(for key: String) throws -> Data?
    func removeObject(for key: String) throws
}

public final class InMemoryCacheService: InMemoryCacheServiceProtocol {
    public static let shared = InMemoryCacheService()
    
    internal lazy var cache: InMemoryCache = {
        let cache = InMemoryCache()
        cache.countLimit = 500
        // maximum of ~105 megabytes (above which
        // items could be evicted from memory)
        cache.totalCostLimit = 100 * 1024 * 1024
        return cache
    }()
    
    func set(object: Data, for key: String) throws {
        guard !key.isEmpty else {
            throw InMemoryCacheServiceError.keyIsAnEmptyString
        }
        
        cache.setObject(object as NSData, forKey: NSString(string: key))
    }
    
    func retrieveObject(for key: String) throws -> Data? {
        guard !key.isEmpty else {
            throw InMemoryCacheServiceError.keyIsAnEmptyString
        }
        
        return cache.object(forKey: NSString(string: key)) as? Data
    }
    
    func removeObject(for key: String) throws {
        guard !key.isEmpty else {
            throw InMemoryCacheServiceError.keyIsAnEmptyString
        }
        
        cache.removeObject(forKey: NSString(string: key))
    }
}

public enum InMemoryCacheServiceError: Error {
    case keyIsAnEmptyString
}
